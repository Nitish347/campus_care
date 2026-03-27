import os, re

screens_dir = r"d:\campus_care\campus_care\lib\screens\admin"
import_statement = "import 'package:campus_care/widgets/admin/admin_page_header.dart';\n"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'appBar: AppBar(' not in content and 'appBar: const AppBar(' not in content:
        return

    # To handle multiple app bars
    last_idx = 0
    new_content = ""
    modified = False

    while True:
        # Match both const AppBar and AppBar
        match = re.search(r'([ \t]*)appBar:\s*(?:const\s+)?AppBar\s*\(', content[last_idx:])
        if not match:
            new_content += content[last_idx:]
            break
            
        start_idx = last_idx + match.end() - 1 # Points to the opening '('
        prefix = content[last_idx:last_idx + match.start()]
        indent = match.group(1)
        
        # Find closing parenthesis using brace counting
        depth = 0
        end_idx = -1
        for i in range(start_idx, len(content)):
            if content[i] == '(':
                depth += 1
            elif content[i] == ')':
                depth -= 1
                if depth == 0:
                    end_idx = i
                    break
                    
        if end_idx == -1:
            # Parsing failed, skip this one
            new_content += content[last_idx:last_idx + match.end()]
            last_idx += match.end()
            continue
            
        inner_content = content[start_idx+1:end_idx]
        
        # Extract title if it's Text(...)
        title_text = "Admin Area"
        # Try to find title: Text('...') or title: const Text('...')
        title_match = re.search(r"title:\s*(?:const\s+)?Text\s*\(\s*'([^']+)'(?:[^)]*)\)\s*(?:,)?", inner_content)
        if title_match:
            title_text = title_match.group(1)
            # Remove the title from inner content to replace it
            inner_content = inner_content[:title_match.start()] + inner_content[title_match.end():]
        
        # Clean up leading commas/spaces if any
        inner_content = inner_content.strip()
        
        replacement = f"{indent}appBar: AdminPageHeader(\n{indent}  title: '{title_text}',\n{indent}  showBackButton: true,"
        if inner_content:
            if not replacement.endswith("\n"):
                replacement += f"\n{indent}  "
            replacement += "\n  " + inner_content.replace("\n", "\n  ")
        replacement += f"\n{indent})"
        
        new_content += prefix + replacement
        last_idx = end_idx + 1
        modified = True

    if modified:
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
