# Copyright 2023 Xenetek. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This program uses material from the Wikipedia article "Web colors",
# which is released under the Creative Commons Attribution-Share-Alike License 3.0.

#
# generate X11 color constants (+RebeccaPurple).
#

colors = {
  # pink colors.
  'mediumVioletRed': '0xFFC71585',
  'deepPink': '0xFFFF1493',
  'paleVioletRed': '0xFFDB7093',
  'hotPink': '0xFFFF69B4',
  'lightPink': '0xFFFFB6C1',
  'pink': '0xFFFFC0CB',

  # red colors.
  'darkRed': '0xFF8B0000',
  'red': '0xFFFF0000',
  'firebrick': '0xFFB22222',
  'crimson': '0xFFDC143C',
  'indianRed': '0xFFCD5C5C',
  'lightCoral': '0xFFF08080',
  'salmon': '0xFFFA8072',
  'darkSalmon': '0xFFE9967A',
  'lightSalmon': '0xFFFFA07A',

  # orange colors.
  'orangeRed': '0xFFFF4500',
  'tomato': '0xFFFF6347',
  'darkOrange': '0xFFFF8C00',
  'coral': '0xFFFF7F50',
  'orange': '0xFFFFA500',

  # yellow colors.
  'darkKhaki': '0xFFBDB76B',
  'gold': '0xFFFFD700',
  'khaki': '0xFFF0E68C',
  'peachPuff': '0xFFFFDAB9',
  'yellow': '0xFFFFFF00',
  'paleGoldenrod': '0xFFEEE8AA',
  'moccasin': '0xFFFFE4B5',
  'papayaWhip': '0xFFFFEFD5',
  'lightGoldenrodYellow': '0xFFFAFAD2',
  'lemonChiffon': '0xFFFFFACD',
  'lightYellow': '0xFFFFFFE0',

  # brown colors.
  'maroon': '0xFF800000',
  'brown': '0xFFA52A2A',
  'saddleBrown': '0xFF8B4513',
  'sienna': '0xFFA0522D',
  'chocolate': '0xFFD2691E',
  'darkGoldenrod': '0xFFB8860B',
  'peru': '0xFFCD853F',
  'rosyBrown': '0xFFBC8F8F',
  'goldenrod': '0xFFDAA520',
  'sandyBrown': '0xFFF4A460',
  'tan': '0xFFD2B48C',
  'burlywood': '0xFFDEB887',
  'wheat': '0xFFF5DEB3',
  'navajoWhite': '0xFFFFDEAD',
  'bisque': '0xFFFFE4C4',
  'blanchedAlmond': '0xFFFFEBCD',
  'cornsilk': '0xFFFFF8DC',

  # purple, violet, and magenta colors.
  'indigo': '0xFF4B0082',
  'rebeccaPurple': '0xFF663399',
  'purple': '0xFF800080',
  'darkMagenta': '0xFF8B008B',
  'darkViolet': '0xFF9400D3',
  'darkSlateBlue': '0xFF483D8B',
  'blueViolet': '0xFF8A2BE2',
  'darkOrchid': '0xFF9932CC',
  'fuchsia': '0xFFFF00FF',
  'magenta': '0xFFFF00FF',
  'slateBlue': '0xFF6A5ACD',
  'mediumSlateBlue': '0xFF7B68EE',
  'mediumOrchid': '0xFFBA55D3',
  'mediumPurple': '0xFF9370DB',
  'orchid': '0xFFDA70D6',
  'violet': '0xFFEE82EE',
  'plum': '0xFFDDA0DD',
  'thistle': '0xFFD8BFD8',
  'lavender': '0xFFE6E6FA',

  # green colors.
  'darkGreen': '0xFF006400',
  'green': '0xFF008000',
  'darkOliveGreen': '0xFF556B2F',
  'forestGreen': '0xFF228B22',
  'seaGreen': '0xFF2E8B57',
  'olive': '0xFF808000',
  'oliveDrab': '0xFF6B8E23',
  'mediumSeaGreen': '0xFF3CB371',
  'limeGreen': '0xFF32CD32',
  'lime': '0xFF00FF00',
  'springGreen': '0xFF00FF7F',
  'mediumSpringGreen': '0xFF00FA9A',
  'darkSeaGreen': '0xFF8FBC8F',
  'mediumAquamarine': '0xFF66CDAA',
  'yellowGreen': '0xFF9ACD32',
  'lawnGreen': '0xFF7CFC00',
  'chartreuse': '0xFF7FFF00',
  'lightGreen': '0xFF90EE90',
  'greenYellow': '0xFFADFF2F',
  'paleGreen': '0xFF98FB98',

  # cyan colors.
  'teal': '0xFF008080',
  'darkCyan': '0xFF008B8B',
  'lightSeaGreen': '0xFF20B2AA',
  'cadetBlue': '0xFF5F9EA0',
  'darkTurquoise': '0xFF00CED1',
  'mediumTurquoise': '0xFF48D1CC',
  'turquoise': '0xFF40E0D0',
  'aqua': '0xFF00FFFF',
  'cyan': '0xFF00FFFF',
  'aquamarine': '0xFF7FFFD4',
  'paleTurquoise': '0xFFAFEEEE',
  'lightCyan': '0xFFE0FFFF',

  # blue colors.
  'midnightBlue': '0xFF191970',
  'navy': '0xFF000080',
  'darkBlue': '0xFF00008B',
  'mediumBlue': '0xFF0000CD',
  'blue': '0xFF0000FF',
  'royalBlue': '0xFF4169E1',
  'steelBlue': '0xFF4682B4',
  'dodgerBlue': '0xFF1E90FF',
  'deepSkyBlue': '0xFF00BFFF',
  'cornflowerBlue': '0xFF6495ED',
  'skyBlue': '0xFF87CEEB',
  'lightSkyBlue': '0xFF87CEFA',
  'lightSteelBlue': '0xFFB0C4DE',
  'lightBlue': '0xFFADD8E6',
  'powderBlue': '0xFFB0E0E6',

  # white colors.
  'mistyRose': '0xFFFFE4E1',
  'antiqueWhite': '0xFFFAEBD7',
  'linen': '0xFFFAF0E6',
  'beige': '0xFFF5F5DC',
  'whiteSmoke': '0xFFF5F5F5',
  'lavenderBlush': '0xFFFFF0F5',
  'oldLace': '0xFFFDF5E6',
  'aliceBlue': '0xFFF0F8FF',
  'seashell': '0xFFFFF5EE',
  'ghostWhite': '0xFFF8F8FF',
  'honeydew': '0xFFF0FFF0',
  'floralWhite': '0xFFFFFAF0',
  'azure': '0xFFF0FFFF',
  'mintCream': '0xFFF5FFFA',
  'snow': '0xFFFFFAFA',
  'ivory': '0xFFFFFFF0',
  'white': '0xFFFFFFFF',

  # gray and black colors.
  'black': '0xFF000000',
  'darkSlateGray': '0xFF2F4F4F',
  'dimGray': '0xFF696969',
  'slateGray': '0xFF708090',
  'gray': '0xFF808080',
  'lightSlateGray': '0xFF778899',
  'darkGray': '0xFFA9A9A9',
  'silver': '0xFFC0C0C0',
  'lightGray': '0xFFD3D3D3',
  'gainsboro': '0xFFDCDCDC',
}

def main():
  print('import \'package:flutter/material.dart\';\n')
  print('/// X11 colors (+RebeccaPurple)')
  print('///')
  print('/// from https://en.wikipedia.org/wiki/Web_colors#Extended_colors.\n')

  print('class X11Colors {')
  for key in colors:
    print('static const ' + key + ' = Color(' + colors[key] + ');')

  print('static const colors = <Color>[')
  for key in colors:
    print('X11Colors.' + key + ',')
  print('];\n')

  print('}')

  print('const x11Colors = X11Colors.colors;')

  print('const x11ColorNames = <String>[')

  for key in colors:
    print('\'' + key +'\',')

  print('];\n')

# end of main.

if __name__ == "__main__":
    main()
    