from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class DeploymentTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="skills deployment ")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.source = self.directory / "skills"
        self.alias_file = self.directory / "aliases"
        self.original = "alias ll='ls -l'\nskills() { printf 'old output\\n'; }\n"
        self.alias_file.write_text(self.original)
        self.add_skill("code/demo", "Run the demo")
        self.add_skill("maintain/update-agent-instructions", "Update agent instructions")

    def add_skill(self, name, description):
        path = self.source / name / "SKILL.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"---\nname: {path.parent.name}\ndescription: {description}\n---\n")
        return path

    def deploy(self, *targets, source=None, check=True):
        return subprocess.run([
            "make", "-j3", *targets,
            f"SKILLS_SRC={source or self.source}", f"ALIASES_FILE={self.alias_file}",
            f"COPILOT_TARGET_DIR={self.directory / 'copilot'}",
            f"CLAUDE_SKILLS_DIR={self.directory / 'claude'}",
            f"CLAUDE_ALT_SKILLS_DIR={self.directory / 'claude-alt'}",
            f"CODEX_TARGET_DIR={self.directory / 'codex'}",
        ], cwd=ROOT, text=True, capture_output=True, check=check)

    def skills_output(self):
        subprocess.run(["bash", "-n", str(self.alias_file)], check=True)
        return subprocess.run([
            "bash", "--noprofile", "--norc", "-c", '. "$1"; skills',
            "bash", str(self.alias_file),
        ], text=True, capture_output=True, check=True).stdout

    def test_each_deployment_refreshes_aliases(self):
        for target in ("deploy-copilot", "deploy-claude", "deploy-codex"):
            with self.subTest(target=target):
                self.alias_file.write_text(self.original)
                result = self.deploy(target)
                self.assertEqual(result.stdout.count("Updated skills function"), 1)
                self.assertIn("Run the demo", self.skills_output())
                self.assertTrue(self.alias_file.read_text().startswith(self.original))

    def test_default_target_still_deploys_copilot(self):
        self.deploy()
        self.assertTrue((self.directory / "copilot/code/demo/SKILL.md").is_file())
        self.assertFalse((self.directory / "codex").exists())

    def test_parallel_deploy_all_runs_updater_once_and_is_repeatable(self):
        result = self.deploy("deploy-all")
        self.assertEqual(result.stdout.count("Updated skills function"), 1)
        first = self.alias_file.read_bytes()
        self.deploy("deploy-all")
        self.assertEqual(self.alias_file.read_bytes(), first)
        for destination in ("copilot/maintain", "claude/skills-pay-the-bills/maintain",
                            "claude-alt/skills-pay-the-bills/maintain", "codex"):
            self.assertTrue((self.directory / destination / "update-agent-instructions/SKILL.md").is_file())
        output = self.skills_output()
        header_column = output.splitlines()[0].index("Description")
        row = next(line for line in output.splitlines() if "update-agent-instructions" in line)
        self.assertEqual(row.index("Update agent instructions"), header_column)

    def test_updates_descriptions_and_removes_deleted_skills(self):
        self.deploy("deploy-copilot")
        self.add_skill("code/demo", "A new description")
        (self.source / "maintain/update-agent-instructions/SKILL.md").unlink()
        self.deploy("deploy-copilot")
        output = self.skills_output()
        self.assertIn("A new description", output)
        self.assertNotIn("Run the demo", output)
        self.assertNotIn("update-agent-instructions", output)
        self.assertEqual(self.alias_file.read_text().count("# BEGIN skills-pay-the-bills skills"), 1)

    def test_subset_source_and_literal_shell_characters(self):
        marker = self.directory / "must not exist"
        summary = f"Literal $(touch '{marker}') `echo surprise` $USER"
        self.add_skill("code/demo", summary)
        self.deploy("deploy-copilot", source=self.source / "code")
        output = self.skills_output()
        self.assertIn(summary, " ".join(output.split()))
        self.assertFalse(marker.exists())
        self.assertNotIn("maintain", output)

    def test_invalid_source_leaves_aliases_and_destinations_untouched(self):
        result = self.deploy("deploy-all", source=self.directory / "missing", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.alias_file.read_text(), self.original)
        self.assertFalse((self.directory / "copilot").exists())

    def test_creates_missing_alias_file_and_supports_folded_descriptions(self):
        self.alias_file = self.directory / "new directory" / "aliases"
        self.add_skill("code/demo", ">-\n  First line\n  second line")
        self.deploy("deploy-copilot")
        self.assertIn("First line second line", self.skills_output())


if __name__ == "__main__":
    unittest.main()
