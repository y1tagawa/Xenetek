# Copyright 2022 Xenetek. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

#
# Generate flutter sources for open_moji_svgs.
#

import json

def main():
    f = open('table.json', 'r', encoding='utf-8')
    data = json.load(f)

    # target index list.
    indices = [
        # crown, ghost
        109, 112,
        # monkey faces
        125, 126, 127,
        # people
        350, 354, 358, 378, 380, 390, 395, 399,
        # animals
                            534, 535, 536, 537, 538, 539,
        540, 541, 542, 543, 544, 545, 546, 547, 548, 549,
        550, 551, 552, 553,           556, 557, 558, 559,
        560, 561, 562, 563, 564, 565, 566, 567, 568, 569,
        570, 571, 572, 573, 574, 575, 576, 577, 578, 579,
        580, 581, 582, 583, 584, 585, 586, 587, 588, 589,
        590, 591, 592, 593, 594, 595, 596, 597, 598, 599,
        600, 601, 602, 603, 604, 605, 606, 607, 608, 609,
        610, 611, 612, 613, 614, 615, 616, 617,
             621, 622, 623, 624, 625, 626, 627, 628, 629,
        630, 631, 632, 633, 634, 635, 636, 637, 638, 639,
        640,      642, 643, 644, 645, 646, 647, 648, 649,
        650, 651, 652, 653, 654, 655, 656, 657,
                       773, 774, 775, 776, 777,
    ]

    # generate downloader

    of = open('download.sh', 'w', encoding='utf-8', newline='\n')
    of.write('#!/bin/sh\n')
    for index in indices:
        item = data[str(index)]
        fileName = item['code'].upper() + '.svg'
        of.write('wget -nc -O assets/' + fileName + ' https://openmoji.org/data/color/svg/' + fileName + ' 2>>download.log\n')

# end of main.

if __name__ == "__main__":
    main()
