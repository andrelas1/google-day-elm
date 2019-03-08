"use strict";

require("./styles/index.scss");

var ElmModule = require("./Main.elm");
var mountNode = document.getElementById("main");

var app = ElmModule.Elm.Main.init({
  node: mountNode
});
