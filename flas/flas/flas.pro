TEMPLATE = aux
TARGET = flas

RESOURCES += flas.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  flas.apparmor \
               flas.png \
               hint1.png \
               hint2.png

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)               

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               flas.desktop

#specify where the qml/js files are installed to
qml_files.path = /flas
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /flas
config_files.files += $${CONF_FILES}

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /flas
desktop_file.files = $$OUT_PWD/flas.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files desktop_file

DISTFILES += \
    RadioMainPage.qml \
    AnimatedLabel.qml \
    FavoritesListModel.qml \
    FavoritesPage.qml \
    FavoriteListItemDelegate.qml \
    hint1.png \
    hint2.png \
    Share.qml \
    ContentHandler.qml \
    MimeTypeMapper.js \
    ContentShareDialog.qml \
    HeaderDelegate.qml \
    NoInternetPopOver.qml \
    RatingIndicator.qml \
    ../manifest.json \
    Tab2.qml \
    Tab1.qml

