/**
 * Based on https://github.com/amarchen/Wikipedia/blob/master/src/qml/components/DbDictionary.qml
 * by Artem Marchenko
 * License is Attribution-NonCommercial-ShareAlike 3.0 Unported (http://creativecommons.org/licenses/by-nc-sa/3.0/)
 *
 * A storage based on LocalStorage
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0 as LS

// @TODO: exception handling e.g. when creating db

QtObject {
    // Could be "MyAppSettings"
    property string dbName: 'MyAppSettings';

    // Most of the time you are not interested in even knowing it
    property string dbDescription: dbName;

    property string dbVersion: '1.0';

    // Estimated size of DB in bytes. Just a hint for the engine and is ignored as of Qt 5.0 I think
    property int estimatedSize: 10000;

    function tableExists(table) {
        var db = getDatabase();
        var exists = false;
        db.transaction(
            function(tx) {
                try {
                    var result = tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name='" + table + "';");
                    exists = result.rows.length > 0;
                } catch(e) {
                    if(e.code === SQLException.DATABASE_ERR) {
                        console.warn('Database error:', e.message);
                    } else if(e.code === SQLException.SYNTAX_ERR) {
                        console.warn('Database syntax error:', e.message);
                    } else {
                        console.warn('Database unknown error:', e.message);
                    }

                    exists = false;
                }
            }
        );
        return exists;
    }

    function cleanTable(table) {
        var db = getDatabase();
        db.transaction(
            function(tx) {
                try {
                    // Apparently variable interpolation doesn't work in this case...?
                    tx.executeSql('DELETE FROM ' + table);
                } catch(e) {
                    console.log('DB error in cleanTable')
                    if(e.code === SQLException.DATABASE_ERR) {
                        console.warn('Database error:', e.message);
                    } else if(e.code === SQLException.SYNTAX_ERR) {
                        console.warn('Database syntax error:', e.message);
                    } else {
                        console.warn('Database unknown error:', e.message);
                    }

                    return false;
                }
            }
        );
        return true;
    }

    function getDatabase() {
        //console.log('Trying to open:', dbName);
        try {
            var db = LS.LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, estimatedSize);
            return db;
        } catch(e) {
            if(e.code === SQLException.DATABASE_ERR) {
                console.warn('Database error:', e.message);
            } else if(e.code === SQLException.VERSION_ERR) {
                console.warn('Database version error:', e.message);
            } else {
                console.warn('Database unknown error:', e.message);
            }

            return false;
        }
    }

    function getTimerTable() {
        var db = getDatabase();
        db.transaction(
            function(tx) {
                try {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS timers(name TEXT, minutes INT, seconds INT, PRIMARY KEY(name))');
                } catch(e) {
                    if(e.code === SQLException.DATABASE_ERR) {
                        console.warn('Database error:', e.message);
                    } else if(e.code === SQLException.SYNTAX_ERR) {
                        console.warn('Database syntax error:', e.message);
                    } else {
                        console.warn('Database unknown error:', e.message);
                    }

                    return false;
                }
            }
        );
        return db;
    }

    /**
     * @param string name
     * @param int minutes
     * @param int seconds
     * @return bool
     */
    function saveTimer(name, minutes, seconds) {
        var db = getTimerTable();
        var result;

        db.transaction(
            function(tx) {
                try {
                    var result = tx.executeSql('INSERT OR REPLACE INTO timers VALUES (?,?,?);', [name, minutes, seconds]);
                } catch(e) {
                    if(e.code === SQLException.DATABASE_ERR) {
                        console.warn('Database error:', e.message);
                    } else if(e.code === SQLException.SYNTAX_ERR) {
                        console.warn('Database syntax error:', e.message);
                    } else {
                        console.warn('Database unknown error:', e.message);
                    }

                    return false;
                }
                //console.log('Affected rows:', result.rowsAffected)
                if (result.rowsAffected > 0) {
                    console.debug('Saved ' + minutes + ':' + seconds + ' for ' + name)
                    return true;
                } else {
                    //@TODO handle error on saving
                    console.error('ERROR: Storage: Failed to: ' + name + ',' + minutes + ':' + seconds);
                    return false;
                }
            }
        );
    }

    /**
     * @param array timers
     * @return bool
     */
    function saveTimers(timers) {
        if(!cleanTable('timers')) {
            return false;
        }

        for (var i = 0; i < timers.length; ++i) {
            var timer = timers[i];
            saveTimer(timer.name, timer.minutes, timer.seconds);
        }

        return true;
    }

    /**
     * @param defaultValue Optional, you get it if wanted property is not found in DB
     * @return Value saved at a given name or defaultValue if not found or undefined if not found and
     *               defaultValue is not specified
     */
    function getTimers() {

        var tableExisted = tableExists("timers")
        var db = getTimerTable();
        var timers = [];
        var result = false;
        var defaultTimers = [
            {name: qsTr('Eggs'), minutes: 7, seconds: 30},
            {name: qsTr('Potatoes'), minutes: 15, seconds: 0},
            {name: qsTr('Frozen pizza'), minutes: 14, seconds: 0},
            {name: qsTr('Tea (Earl Grey)'), minutes: 5, seconds: 20},
        ];


        db.transaction(
            function(tx) {
                try {
                    result = tx.executeSql('SELECT * FROM timers;');
                } catch(e) {
                    if(e.code === SQLException.DATABASE_ERR) {
                        console.warn('Database error:', e.message);
                    } else if(e.code === SQLException.SYNTAX_ERR) {
                        console.warn('Database version error:', e.message);
                    } else {
                        console.warn('Database unknown error:', e.message);
                    }

                    return false;
                }

                if (result.rows.length > 0) {
                    for (var i = 0; i < result.rows.length; ++i) {
                        var row = result.rows.item(i);
                        timers.push(
                            {name: row.name, minutes: row.minutes, seconds: row.seconds}
                        );
                    }
                } else {
                    console.debug("Storage: No values for timers. Table existed?", tableExisted);
                    // Don't load default timers if user deleted them on purpose
                    if(!tableExisted) {
                        timers = defaultTimers;
                        for (var i = 0; i < timers.length; ++i) {
                            var timer = timers[i];
                            saveTimer(timer.name, timer.minutes, timer.seconds);
                        }
                    }
                }
            }
        );
        return timers;
    }
}
