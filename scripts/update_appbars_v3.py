import os, re

screens_dir = r"d:\campus_care\campus_care\lib\screens\admin"
import_statement = "import 'package:campus_care/widgets/admin/admin_page_header.dart';\n"

for root, dirs, files in os.walk(screens_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'appBar: AppBar(' in content or 'appBar: const AppBar(' in content:
                content = re.sub(r'([ \t]*)appBar:\s*(?:const\s+)?AppBar\(', r'\1appBar: AdminPageHeader(\n\1  showBackButton: true,', content)
                
                # Remove elevation or backgroundColor if immediately inside the new AdminPageHeader
                # We can't guarantee it's inside, but it's safe enough if we only strip it from the header block.
                # Actually, I won't strip them here. I'll let flutter analyze catch them.

                if 'admin_page_header.dart' not in content:
                    imports = list(re.finditer(r"^import\s+['\"].*?['\"];\s*$", content, re.MULTILINE))
                    if imports:
                        last_import = imports[-1]
                        insert_pos = last_import.end() + 1
                        content = content[:insert_pos] + import_statement + content[insert_pos:]
                    else:
                        content = import_statement + content
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {file}")
