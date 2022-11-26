// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

void addLicenses() {
  LicenseRegistry.addLicense(() {
    return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
      const LicenseEntryWithLineBreaks(<String>['OpenMoji'], '''
CC BY-SA 4.0 license\n
https://creativecommons.org/licenses/by-sa/4.0/
    '''),
      const LicenseEntryWithLineBreaks(<String>['svg-repo-svg.svg'], '''
Public Domain\n
https://www.svgrepo.com/page/licensing/\n\n
The person who associated a work with this deed has dedicated the work to the public domain by waiving all of his or her rights to the work worldwide under copyright law, including all related and neighboring rights, to the extent allowed by law.
Or, the work consists of simple geometry and is not ineligable for copyright due to Threshold of originality (this threshold might vary depending on different country laws). For an example "A stick figure, where the head is represented by a circle and other parts represented by straight lines" is not copyrightable or falls into public domain.
You are free:\n
* to share – to copy, distribute and transmit the work\n
* to remix – to adapt the work\n
Under the following terms:\n
* attribution – there is no author or author waived their right, no attribution\n
* share alike – If you remix, transform, or build upon the material, you can distribute your work under any license.\n
    '''),
    ]);
  });
}
