import os, re

screens_dir = r"d:\campus_care\campus_care\lib\screens\admin"
import_statement = "import 'package:campus_care/widgets/admin/admin_page_header.dart';\n"

# Match appBar: AppBar(...) block
# Note: we assume the AppBar ends with a closing paren followed by a comma
appbar_pattern = re.compile(
    r'(?P<indent>[ \t]*)appBar:\s*AppBar\s*\((?P<inner>.*?)\)\s*,',
    re.DOTALL
)

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'appBar: AppBar(' not in content:
        return

    def replacer(match):
        inner = match.group('inner')
        indent = match.group('indent')
        
        # Extract title text
        title_match = re.search(r"title:\s*(?:const\s+)?Text\s*\(\s*'([^']+)'(?:[^)]*)\)", inner)
        title_text = title_match.group(1) if title_match else 'Admin Area'
        
        return f"{indent}appBar: const AdminPageHeader(\n{indent}  title: '{title_text}',\n{indent}  showBackButton: true,\n{indent}),"

    new_content, count = appbar_pattern.subn(replacer, content)
    
    if count > 0:
        if 'admin_page_header.dart' not in new_content:
            # Insert after the last import
            imports = list(re.finditer(r"^import\s+['\"].*?['\"];\s*$", new_content, re.MULTILINE))
            if imports:
                last_import = imports[-1]
                insert_pos = last_import.end() + 1
                new_content = new_content[:insert_pos] + import_statement + new_content[insert_pos:]
            else:
                new_content = import_statement + new_content
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {os.path.basename(filepath)}")

for root, dirs, files in os.walk(screens_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
