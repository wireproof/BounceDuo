from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
template = root / 'tools/ios-4.3/ios.zip'
preset = root / 'game/export_presets.cfg'
value = str(template) if template.is_file() else ''
text = preset.read_text()
for kind in ('debug', 'release'):
    text = re.sub(r'custom_template/' + kind + r'="[^"]*"', lambda _: 'custom_template/' + kind + '="' + value + '"', text)
preset.write_text(text)
