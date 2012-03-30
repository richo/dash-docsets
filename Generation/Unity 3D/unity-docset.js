var fs = require('fs');
var system = require('system');

var docRoot = 'Unity.docset/Contents/Resources/Documents/docs/';
console.log('Using docroot', docRoot);

var globalPage = new WebPage();
var tokensFile = fs.open('Unity.docset/Contents/Resources/Tokens.xml', 'w');
tokensFile.writeLine('<?xml version="1.0" encoding="UTF-8"?>');
tokensFile.writeLine('<Tokens version="1.0">');

var classFiles, enumFiles, classMemberFiles = [], enumMemberFiles = [];

var chain = [loadClassHierarchy,
             loadEnumHierarchy,
             parseClassFiles,
             parseEnumFiles,
             parseClassMemberFiles,
             parseEnumMemberFiles,
             cleanup];

runChain(chain);

function runChain(chain) {
    var index = 0;
    stepChain();

    function stepChain() {
        if (index == chain.length) return;

        var f = chain[index];
        ++index;

        f(stepChain);
    }
}

function cleanup() {
    tokensFile.writeLine('</Tokens>');
    tokensFile.close();
    phantom.exit();
}

function loadClassHierarchy(success) {
    console.log('Loading class hierarchy...');
    findChildClasslinks('ScriptReference/20_class_hierarchy.html', function(links) {
        classFiles = links;
        console.log('Found ' + classFiles.length + ' class files');
        success();
    })
}

function loadEnumHierarchy(success) {
    console.log('Loading enum hierarchy...');
    findChildClasslinks('ScriptReference/20_class_hierarchy.Enumerations.html', function(links) {
        enumFiles = links;
        console.log('Found ' + enumFiles.length + ' enum files');
        success();
    });
}

function parseClassFiles(success) {
    console.log('Parsing ' + classFiles.length + ' class files...');
    var fileSet = {};
    chainMap(classFiles, function(file, nextFile) {
        parseTypePage(file, function(typeName, memberLinks) {
            var isInterface = typeName.match(/^I[A-Z]/);
            writeToken(file, isInterface ? 'intf' : 'cl', typeName);
            unionSet(fileSet, removeQueryStrings(memberLinks));
            nextFile();
        });
    }, function() {
        classMemberFiles = arrayFromSet(fileSet);
        success();
    });
}

function parseEnumFiles(success) {
    console.log('Parsing ' + enumFiles.length + ' enum files...');
    var fileSet = {};
    chainMap(enumFiles, function(file, nextFile) {
        parseTypePage(file, function(typeName, memberLinks) {
            writeToken(file, 'tdef', typeName);
            unionSet(fileSet, removeQueryStrings(memberLinks));
            nextFile();
        });
    }, function() {
        enumMemberFiles = arrayFromSet(fileSet);
        success();
    });
}

function parseClassMemberFiles(success) {
    console.log('Parsing ' + classMemberFiles.length + ' class member files...');
    var page = parseClassMemberFiles.page;
    chainMap(classMemberFiles, function(file, nextFile) {
        page.open(file, function(status) {
            abortOnFailure(status);

            var memberName = page.evaluate(function() {
                return document.querySelectorAll('span.heading')[0].innerText;
            });
            var kind = page.evaluate(function() {
                var entries = document.querySelectorAll('.manual-entry h3 .hl-keyword');
                var result = 'clm';
                for (var i = 0; i < entries.length; ++i) {
                    if (entries[i].innerText === 'var') {
                        result = 'instp';
                    } else if (entries[i].innerText === 'static') {
                        result = 'func';
                    }
                }

                return result;
            })

            writeToken(file, kind, memberName);
            nextFile();
        });
    }, success);
}
parseClassMemberFiles.page = new WebPage();

function parseEnumMemberFiles(success) {
    console.log('Parsing ' + enumMemberFiles.length + ' enum member files...');
    var page = parseEnumMemberFiles.page;
    chainMap(enumMemberFiles, function(file, nextFile) {
        page.open(file, function(status) {
            abortOnFailure(status);

            var memberName = page.evaluate(function() {
                return document.querySelectorAll('span.heading')[0].innerText;
            });

            writeToken(file, 'econst', memberName);
            nextFile();
        });
    }, success);
}
parseEnumMemberFiles.page = new WebPage();

function parseTypePage(relativePath, success) {
    var page = parseTypePage.page;
    page.open(relativePath, function(status) {
        abortOnFailure(status);

        var typeName = page.evaluate(function() {
            return document.querySelectorAll('span.heading')[0].innerText;
        });

        var filenames = page.evaluate(function() {
            var memberElements = document.querySelectorAll('td.class-member-list-name a');
            var foundFiles = [];

            for (var i = 0; i < memberElements.length; ++i) {
                var href = memberElements[i].href;
                foundFiles.push(href);
            }

            return foundFiles;
        });

        success(typeName, filenames);
    });
}
parseTypePage.page = new WebPage(); // Reuse WebPage instance for performance

function chainMap(items, f, success) {
    var index = 0;
    stepMap();

    function stepMap() {
        if (index == items.length) {
            success();
            return;
        }

        console.log('Mapping item ' + (index+1) + '/' + items.length);
        var item = items[index];
        ++index;

        f(item, stepMap);
    }
}

function removeQueryStrings(filenames) {
    var a = new Array(filenames.length);
    for (var i = 0; i < filenames.length; ++i) {
        var fn = filenames[i];
        if (filenames[i].indexOf('?') != -1) {
            fn = filenames[i].substring(0, filenames[i].indexOf('?'));
        }
        a[i] = fn;
    }
    return a;
}

function writeToken(path, type, name) {
    var pathTokens = path.split('/');
    var filename = pathTokens[pathTokens.length - 1];
    name = name.replace('/', '\\/');

    var context = name.split('.')[0];
    if (context != name) {
        name = context + '/' + name;
    }
    tokensFile.writeLine('<File path="docs/ScriptReference/' + filename + '">');
    tokensFile.writeLine('  <Token>');
    tokensFile.writeLine('    <TokenIdentifier>//apple_ref/cpp/' + type + '/' + name + '</TokenIdentifier>');
    tokensFile.writeLine('  </Token>');
    tokensFile.writeLine('</File>');
}

function findChildClasslinks(relativePath, success) {
    var page = new WebPage();

    page.open(docRoot + relativePath, function(status) {
        abortOnFailure(status);

        success(page.evaluate(function() {
            var linkElements = document.querySelectorAll('li a.classlink');
            var links = [];
            for (var i = 0; i < linkElements.length; ++i) {
                links.push(linkElements[i].href);
            }
            return links;
        }));
    });
}

function abortOnFailure(status) {
    if (status !== 'success') {
        console.log('Failure:', status);
        phantom.exit();
    }
}

function unionSet(target, newItems) {
    for (var i = 0; i < newItems.length; ++i) {
        target[newItems[i]] = 1;
    }
}

function arrayFromSet(set) {
    var a = [];
    for (var key in set) {
        if (set.hasOwnProperty(key)) {
            a.push(key);
        }
    }
    return a;
}
