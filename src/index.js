"use strict";

require("./styles/index.scss");
require("../node_modules/materialize-css/dist/css/materialize.min.css");
require("../node_modules/materialize-css/dist/js/materialize.min.js");

var ElmModule = require("./Main.elm");
var mountNode = document.getElementById("main");

var app = ElmModule.Elm.Main.init({
  node: mountNode
});
