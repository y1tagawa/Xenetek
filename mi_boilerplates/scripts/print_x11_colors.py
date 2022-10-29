# Copyright 2022 Xenetek. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This program uses material from the Wikipedia article "Web colors",
# which is released under the Creative Commons Attribution-Share-Alike License 3.0.

#
# generate X11 color constants (+RebeccaPurple).
#

colors = {
  # pink colors.
  'MediumVioletRed': '0xFFC71585',
  'DeepPink': '0xFFFF1493',
  'PaleVioletRed': '0xFFDB7093',
  'HotPink': '0xFFFF69B4',
  'LightPink': '0xFFFFB6C1',
  'Pink': '0xFFFFC0CB',

  # red colors.
  'DarkRed': '0xFF8B0000',
  'Red': '0xFFFF0000',
  'Firebrick': '0xFFB22222',
  'Crimson': '0xFFDC143C',
  'IndianRed': '0xFFCD5C5C',
  'LightCoral': '0xFFF08080',
  'Salmon': '0xFFFA8072',
  'DarkSalmon': '0xFFE9967A',
  'LightSalmon': '0xFFFFA07A',

  # orange colors.
  'OrangeRed': '0xFFFF4500',
  'Tomato': '0xFFFF6347',
  'DarkOrange': '0xFFFF8C00',
  'Coral': '0xFFFF7F50',
  'Orange': '0xFFFFA500',

  # yellow colors.
  'DarkKhaki': '0xFFBDB76B',
  'Gold': '0xFFFFD700',
  'Khaki': '0xFFF0E68C',
  'PeachPuff': '0xFFFFDAB9',
  'Yellow': '0xFFFFFF00',
  'PaleGoldenrod': '0xFFEEE8AA',
  'Moccasin': '0xFFFFE4B5',
  'PapayaWhip': '0xFFFFEFD5',
  'LightGoldenrodYellow': '0xFFFAFAD2',
  'LemonChiffon': '0xFFFFFACD',
  'LightYellow': '0xFFFFFFE0',

  # brown colors.
  'Maroon': '0xFF800000',
  'Brown': '0xFFA52A2A',
  'SaddleBrown': '0xFF8B4513',
  'Sienna': '0xFFA0522D',
  'Chocolate': '0xFFD2691E',
  'DarkGoldenrod': '0xFFB8860B',
  'Peru': '0xFFCD853F',
  'RosyBrown': '0xFFBC8F8F',
  'Goldenrod': '0xFFDAA520',
  'SandyBrown': '0xFFF4A460',
  'Tan': '0xFFD2B48C',
  'Burlywood': '0xFFDEB887',
  'Wheat': '0xFFF5DEB3',
  'NavajoWhite': '0xFFFFDEAD',
  'Bisque': '0xFFFFE4C4',
  'BlanchedAlmond': '0xFFFFEBCD',
  'Cornsilk': '0xFFFFF8DC',

  # purple, violet, and magenta colors.
  'Indigo': '0xFF4B0082',
  'RebeccaPurple': '0xFF663399',
  'Purple': '0xFF800080',
  'DarkMagenta': '0xFF8B008B',
  'DarkViolet': '0xFF9400D3',
  'DarkSlateBlue': '0xFF483D8B',
  'BlueViolet': '0xFF8A2BE2',
  'DarkOrchid': '0xFF9932CC',
  'Fuchsia': '0xFFFF00FF',
  'Magenta': '0xFFFF00FF',
  'SlateBlue': '0xFF6A5ACD',
  'MediumSlateBlue': '0xFF7B68EE',
  'MediumOrchid': '0xFFBA55D3',
  'MediumPurple': '0xFF9370DB',
  'Orchid': '0xFFDA70D6',
  'Violet': '0xFFEE82EE',
  'Plum': '0xFFDDA0DD',
  'Thistle': '0xFFD8BFD8',
  'Lavender': '0xFFE6E6FA',

  # green colors.
  'DarkGreen': '0xFF006400',
  'Green': '0xFF008000',
  'DarkOliveGreen': '0xFF556B2F',
  'ForestGreen': '0xFF228B22',
  'SeaGreen': '0xFF2E8B57',
  'Olive': '0xFF808000',
  'OliveDrab': '0xFF6B8E23',
  'MediumSeaGreen': '0xFF3CB371',
  'LimeGreen': '0xFF32CD32',
  'Lime': '0xFF00FF00',
  'SpringGreen': '0xFF00FF7F',
  'MediumSpringGreen': '0xFF00FA9A',
  'DarkSeaGreen': '0xFF8FBC8F',
  'MediumAquamarine': '0xFF66CDAA',
  'YellowGreen': '0xFF9ACD32',
  'LawnGreen': '0xFF7CFC00',
  'Chartreuse': '0xFF7FFF00',
  'LightGreen': '0xFF90EE90',
  'GreenYellow': '0xFFADFF2F',
  'PaleGreen': '0xFF98FB98',

  # cyan colors.
  'Teal': '0xFF008080',
  'DarkCyan': '0xFF008B8B',
  'LightSeaGreen': '0xFF20B2AA',
  'CadetBlue': '0xFF5F9EA0',
  'DarkTurquoise': '0xFF00CED1',
  'MediumTurquoise': '0xFF48D1CC',
  'Turquoise': '0xFF40E0D0',
  'Aqua': '0xFF00FFFF',
  'Cyan': '0xFF00FFFF',
  'Aquamarine': '0xFF7FFFD4',
  'PaleTurquoise': '0xFFAFEEEE',
  'LightCyan': '0xFFE0FFFF',

  # blue colors.
  'MidnightBlue': '0xFF191970',
  'Navy': '0xFF000080',
  'DarkBlue': '0xFF00008B',
  'MediumBlue': '0xFF0000CD',
  'Blue': '0xFF0000FF',
  'RoyalBlue': '0xFF4169E1',
  'SteelBlue': '0xFF4682B4',
  'DodgerBlue': '0xFF1E90FF',
  'DeepSkyBlue': '0xFF00BFFF',
  'CornflowerBlue': '0xFF6495ED',
  'SkyBlue': '0xFF87CEEB',
  'LightSkyBlue': '0xFF87CEFA',
  'LightSteelBlue': '0xFFB0C4DE',
  'LightBlue': '0xFFADD8E6',
  'PowderBlue': '0xFFB0E0E6',

  # white colors.
  'MistyRose': '0xFFFFE4E1',
  'AntiqueWhite': '0xFFFAEBD7',
  'Linen': '0xFFFAF0E6',
  'Beige': '0xFFF5F5DC',
  'WhiteSmoke': '0xFFF5F5F5',
  'LavenderBlush': '0xFFFFF0F5',
  'OldLace': '0xFFFDF5E6',
  'AliceBlue': '0xFFF0F8FF',
  'Seashell': '0xFFFFF5EE',
  'GhostWhite': '0xFFF8F8FF',
  'Honeydew': '0xFFF0FFF0',
  'FloralWhite': '0xFFFFFAF0',
  'Azure': '0xFFF0FFFF',
  'MintCream': '0xFFF5FFFA',
  'Snow': '0xFFFFFAFA',
  'Ivory': '0xFFFFFFF0',
  'White': '0xFFFFFFFF',

  # gray and black colors.
  'Black': '0xFF000000',
  'DarkSlateGray': '0xFF2F4F4F',
  'DimGray': '0xFF696969',
  'SlateGray': '0xFF708090',
  'Gray': '0xFF808080',
  'LightSlateGray': '0xFF778899',
  'DarkGray': '0xFFA9A9A9',
  'Silver': '0xFFC0C0C0',
  'LightGray': '0xFFD3D3D3',
  'Gainsboro': '0xFFDCDCDC',
}

def main():
  print('import \'package:flutter/material.dart\';\n')
  print('/// X11 colors (+RebeccaPurple)')
  print('///')
  print('/// from https://en.wikipedia.org/wiki/Web_colors#Extended_colors.\n')

  print('const x11Colors = <Color>[')

  for key in colors:
    print('Color(' + colors[key] + '),')

  print('];\n')

  print('const x11ColorNames = <String>[')

  for key in colors:
    print('\'' + key +'\',')

  print('];\n')

# end of main.

if __name__ == "__main__":
    main()
    