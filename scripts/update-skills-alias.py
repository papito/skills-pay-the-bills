"""Refresh a managed shell function containing the deployed skills TOC."""

import json
from pathlib import Path
import re
import sys
import textwrap


BEGIN = "# BEGIN skills-pay-the-bills skills"
END = "# END skills-pay-the-bills skills"


def description(path):
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        raise ValueError(f"Missing frontmatter: {path}")
    end = lines.index("---", 1)
    for index, line in enumerate(lines[1:end], 1):
        if not line.startswith("description:"):
            continue
        value = line.partition(":")[2].strip()
        if value in (">", ">-", ">+", "|", "|-", "|+"):
            block = []
            for continuation in lines[index + 1:end]:
                if continuation and not continuation[0].isspace():
                    break
                block.append(continuation.strip())
            value = " ".join(block)
        elif value.startswith('"'):
            value = json.loads(value)
        elif value.startswith("'") and value.endswith("'"):
            value = value[1:-1].replace("''", "'")
        if value:
            return " ".join(value.split())
    raise ValueError(f"Missing description: {path}")


def render_toc(source):
    if not source.is_dir():
        raise ValueError(f"Skills source is not a directory: {source}")
    skills = []
    for path in sorted(source.rglob("SKILL.md")):
        relative = path.parent.relative_to(source)
        domain = str(relative.parent)
        if domain == ".":
            domain = source.name if relative.parts else source.parent.name
        skills.append((domain, path.parent.name, description(path)))
    skills.sort()
    width = max([len("Name")] + [len(name) + 2 for _, name, _ in skills])
    description_width = max(40, 88 - width - 2)
    rows = [f"{'Name':<{width}}  Description", "─" * width + "  " + "─" * description_width]
    previous_domain = None
    for domain, name, summary in skills:
        if domain != previous_domain:
            if previous_domain is not None:
                rows.append("")
            rows.append(domain)
            previous_domain = domain
        wrapped = textwrap.wrap(summary, width=description_width, break_long_words=False,
                                break_on_hyphens=False)
        rows.append(f"{'  ' + name:<{width}}  {wrapped[0]}")
        rows.extend(" " * (width + 2) + line for line in wrapped[1:])
    if not skills:
        rows.append("No skills found.")
    return "\n".join(rows) + "\n"


def update_aliases(source, alias_file):
    toc = render_toc(source)
    delimiter = "SKILLS_PAY_THE_BILLS_TOC"
    while delimiter in toc.splitlines():
        delimiter += "_"
    block = f"{BEGIN}\nskills() {{\n    command cat <<'{delimiter}'\n{toc}{delimiter}\n}}\n{END}\n"
    content = alias_file.read_text(encoding="utf-8") if alias_file.exists() else ""
    pattern = re.compile(r"(?m)^" + re.escape(BEGIN) + r"\n.*?^" + re.escape(END) + r"(?:\n|$)", re.S)
    if BEGIN in content or END in content:
        if len(pattern.findall(content)) != 1:
            raise ValueError(f"Invalid managed skills block in {alias_file}")
        content = pattern.sub(lambda _: block, content)
    else:
        if content and not content.endswith("\n"):
            content += "\n"
        content += ("\n" if content else "") + block
    alias_file.parent.mkdir(parents=True, exist_ok=True)
    alias_file.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    try:
        update_aliases(Path(sys.argv[1]), Path(sys.argv[2]))
    except (OSError, ValueError) as error:
        sys.exit(str(error))
