# Copyright 2022 Xenetek. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

#
# Generate flutter sources for open_moji_svgs.
#

import json

def main():
    with open('table.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # table index list.
    indices = [
        # crown, ghost
        109, 112,
        # monkey faces
        125, 126, 127,
        # people
        231, 350, 354, 358, 378, 380, 390, 395, 399, 490,
        # animals
                            534, 535, 536, 537, 538, 539,
        540, 541, 542, 543, 544, 545, 546, 547, 548, 549,
        550, 551, 552, 553,           556, 557, 558, 559,
        range(560, 610),
        610, 611, 612, 613, 614, 615, 616, 617,
             621, 622, 623, 624, 625, 626, 627, 628, 629,
        630, 631, 632, 633, 634, 635, 636, 637, 638, 639,
        640,      642, 643, 644, 645, 646, 647, 648, 649,
        650, 651, 652, 653, 654, 655, 656, 657,
                       773, 774, 775, 776, 777,
        # objects
        818, 1319, 1327
    ]

    # item list.
    items = []
    for index in indices:
        if isinstance(index, int):
            items.append(data[str(index)])
        elif isinstance(index, range):
            for i in index:
                items.append(data[str(i)])
        else:
            print('invalid index:' + str(index))

    # add extra items.
    items.append({'name':'donkey', 'code':'E001', 'keywords':'extra-openmoji'})
    items.append({'name':'doe', 'code':'E003', 'keywords':'extra-openmoji'})
    items.append({'name':'spouting-orca', 'code':'E004', 'keywords':'extra-openmoji'})
    items.append({'name':'orca', 'code':'E005', 'keywords':'extra-openmoji'})
    items.append({'name':'narwhal', 'code':'E006', 'keywords':'extra-openmoji'})
    items.append({'name':'beluga', 'code':'E007', 'keywords':'extra-openmoji'})
    items.append({'name':'porpoise', 'code':'E008', 'keywords':'extra-openmoji'})
    items.append({'name':'pigeon', 'code':'E009', 'keywords':'extra-openmoji'})
    items.append({'name':'macaw', 'code':'E010', 'keywords':'extra-openmoji'})
    items.append({'name':'microbe2', 'code':'E011', 'keywords':'extra-openmoji'})

    # generate downloader.'
    with open('download.sh', 'w', encoding='utf-8', newline='\n') as f:
        f.write('#!/bin/sh\n')
        f.write('mkdir -p assets/open_moji\n')
        for item in items:
            fileName = item['code'].upper() + '.svg'
            f.write('wget -nc -O assets/open_moji/' + fileName + ' https://openmoji.org/data/color/svg/' +
             fileName + ' 2>&1 | tee -a download.log\n')

    # generate .yaml fragment,
    with open('fragment.yaml', 'w', encoding='utf-8', newline='\n') as f:
        for item in items:
            fileName = item['code'].upper() + '.svg'
            f.write('  - assets/open_moji/' + fileName + '\n')

    # generate importer.
    with open('open_moji_svgs.dart.txt', 'w', encoding='utf-8', newline='\n') as f:
        f.write('All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0\n')
        f.write('import \'package:flutter_svg/flutter_svg.dart\';\n\n')
        for item in items:
            fileName = item['code'].upper() + '.svg'
            name = 'openMojiSvg' + \
                item['name'].replace('&amp;', ' And ').replace('&gt;', ' Gt ').replace('&lt;', ' Lt ')  \
                    .title().replace(' ', '').replace('-', '') 
            f.write('// ' + item['name'] + ' ' + item['keywords'] + '\n')
            f.write('final ' + name + ' = SvgPicture.asset(\'assets/open_moji/' + fileName + '\');\n')

# end of main.

if __name__ == "__main__":
    main()
