# PTRevolutTask

- Used language: Swift 4
- SDK version: Xcode 9
- Minimum deployment target: iOS 10
- Only portrait mode supported
- Used Dependancies: SWXMLHash for XML parsing. Pods directory is added to repository, so no need of any additional actions to Build and Run

## Overview

The application consists of 2 screens:
- Screen One (Home screen) shows overview of the 3 available currencies and the amount of units in them
- Screen Two is where the actual exchanging is happening. Similar design as on the example

## Functionality

- Rates are being updared every 30 seconds
- Active currency rate and two sections are updated, after response from the ECB rates
- Both sections can be slided in both direction infinitely, causing the values to be recalculated 
- Inability to exchange if there are not enough funds, if values are empty/not set or if the two currencies are the same. User is being notified for all different possibilities
- Upon successful exchange, the first screen is shown again, where the information is updated
