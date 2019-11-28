/*
 * Copyright (C) 2014 Szymon Waliczek.
 *
 * Authors:
 *  Szymon Waliczek <majsterrr@gmail.com>
 *
 * This file is part of rad.io application for Ubuntu Touch.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * README:
 * If you wish to change indicator colours, you have to edit "starred.svg" and "non-starred.svg"
 * in your favorite svg editor eg. Inkscape ( I did implement ColorOverlay component from QtGraphicalEffects 1.0
 * but this makes this component very slow, so to improve porformance this solution is better )
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root
    width: starsRowBG.width
    height: ratingValue > 0 ? units.gu(2) : 0


//    Behavior on height {
//        NumberAnimation {}
//    }


    // component properties
    property int maximumValue: 5
    property double ratingValue: 0
    property double spacingValue: units.gu(0.4)

    // stars background (lighter)
    Row {
        id: starsRowBG
        height: parent.height
        spacing: spacingValue

        Repeater {
            model: maximumValue
            delegate: Icon {
                height: root.height
                width: height
                name: "non-starred"
                color: "white"
            }
        }
    }



    // Stars foreground ( filled start )
    Row {
        height: parent.height
        width: (starsRowBG.width * ratingValue) / maximumValue + (spacing / (maximumValue))
        spacing: spacingValue
        clip: true
        Repeater {
            model: maximumValue

            delegate: Icon {
                height: parent.height
                name: "starred"
                color: "white"
            }

        }


    }
}

