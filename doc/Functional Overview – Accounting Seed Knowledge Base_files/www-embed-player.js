(function(){var g,aa=aa||{},m=this;function p(a){return void 0!==a}
function q(a,b,c){a=a.split(".");c=c||m;a[0]in c||!c.execScript||c.execScript("var "+a[0]);for(var d;a.length&&(d=a.shift());)!a.length&&p(b)?c[d]=b:c[d]?c=c[d]:c=c[d]={}}
function r(a,b){for(var c=a.split("."),d=b||m,e;e=c.shift();)if(null!=d[e])d=d[e];else return null;return d}
function t(){}
function ba(a){a.getInstance=function(){return a.P?a.P:a.P=new a}}
function ca(a){var b=typeof a;if("object"==b)if(a){if(a instanceof Array)return"array";if(a instanceof Object)return b;var c=Object.prototype.toString.call(a);if("[object Window]"==c)return"object";if("[object Array]"==c||"number"==typeof a.length&&"undefined"!=typeof a.splice&&"undefined"!=typeof a.propertyIsEnumerable&&!a.propertyIsEnumerable("splice"))return"array";if("[object Function]"==c||"undefined"!=typeof a.call&&"undefined"!=typeof a.propertyIsEnumerable&&!a.propertyIsEnumerable("call"))return"function"}else return"null";
else if("function"==b&&"undefined"==typeof a.call)return"object";return b}
function da(a){return"array"==ca(a)}
function ea(a){var b=ca(a);return"array"==b||"object"==b&&"number"==typeof a.length}
function u(a){return"string"==typeof a}
function fa(a){return"number"==typeof a}
function ga(a){return"function"==ca(a)}
function ha(a){var b=typeof a;return"object"==b&&null!=a||"function"==b}
function ia(a){return a[ka]||(a[ka]=++la)}
var ka="closure_uid_"+(1E9*Math.random()>>>0),la=0;function ma(a,b,c){return a.call.apply(a.bind,arguments)}
function na(a,b,c){if(!a)throw Error();if(2<arguments.length){var d=Array.prototype.slice.call(arguments,2);return function(){var c=Array.prototype.slice.call(arguments);Array.prototype.unshift.apply(c,d);return a.apply(b,c)}}return function(){return a.apply(b,arguments)}}
function w(a,b,c){w=Function.prototype.bind&&-1!=Function.prototype.bind.toString().indexOf("native code")?ma:na;return w.apply(null,arguments)}
function oa(a,b){var c=Array.prototype.slice.call(arguments,1);return function(){var b=c.slice();b.push.apply(b,arguments);return a.apply(this,b)}}
var x=Date.now||function(){return+new Date};
function y(a,b){function c(){}
c.prototype=b.prototype;a.A=b.prototype;a.prototype=new c;a.prototype.constructor=a;a.Re=function(a,c,f){for(var h=Array(arguments.length-2),k=2;k<arguments.length;k++)h[k-2]=arguments[k];return b.prototype[c].apply(a,h)}}
;function pa(a){if(Error.captureStackTrace)Error.captureStackTrace(this,pa);else{var b=Error().stack;b&&(this.stack=b)}a&&(this.message=String(a))}
y(pa,Error);pa.prototype.name="CustomError";var qa;var ra=String.prototype.trim?function(a){return a.trim()}:function(a){return a.replace(/^[\s\xa0]+|[\s\xa0]+$/g,"")};
function sa(a){return decodeURIComponent(a.replace(/\+/g," "))}
var ta=/&/g,ua=/</g,va=/>/g,wa=/"/g,xa=/'/g,ya=/\x00/g,za=/[\x00&<>"']/;function Aa(a){var b={"&amp;":"&","&lt;":"<","&gt;":">","&quot;":'"'},c;c=m.document.createElement("div");return a.replace(Ba,function(a,e){var f=b[a];if(f)return f;if("#"==e.charAt(0)){var h=Number("0"+e.substr(1));isNaN(h)||(f=String.fromCharCode(h))}f||(c.innerHTML=a+" ",f=c.firstChild.nodeValue.slice(0,-1));return b[a]=f})}
function Ca(a){return a.replace(/&([^;]+);/g,function(a,c){switch(c){case "amp":return"&";case "lt":return"<";case "gt":return">";case "quot":return'"';default:if("#"==c.charAt(0)){var d=Number("0"+c.substr(1));if(!isNaN(d))return String.fromCharCode(d)}return a}})}
var Ba=/&([^;\s<&]+);?/g,Da={"\x00":"\\0","\b":"\\b","\f":"\\f","\n":"\\n","\r":"\\r","\t":"\\t","\x0B":"\\x0B",'"':'\\"',"\\":"\\\\","<":"<"},Ea={"'":"\\'"};
function Fa(a,b){for(var c=0,d=ra(String(a)).split("."),e=ra(String(b)).split("."),f=Math.max(d.length,e.length),h=0;0==c&&h<f;h++){var k=d[h]||"",l=e[h]||"",n=RegExp("(\\d*)(\\D*)","g"),D=RegExp("(\\d*)(\\D*)","g");do{var v=n.exec(k)||["","",""],z=D.exec(l)||["","",""];if(0==v[0].length&&0==z[0].length)break;c=Ga(0==v[1].length?0:parseInt(v[1],10),0==z[1].length?0:parseInt(z[1],10))||Ga(0==v[2].length,0==z[2].length)||Ga(v[2],z[2])}while(0==c)}return c}
function Ga(a,b){return a<b?-1:a>b?1:0}
function Ha(a){for(var b=0,c=0;c<a.length;++c)b=31*b+a.charCodeAt(c)>>>0;return b}
;var Ia=Array.prototype.indexOf?function(a,b,c){return Array.prototype.indexOf.call(a,b,c)}:function(a,b,c){c=null==c?0:0>c?Math.max(0,a.length+c):c;
if(u(a))return u(b)&&1==b.length?a.indexOf(b,c):-1;for(;c<a.length;c++)if(c in a&&a[c]===b)return c;return-1},A=Array.prototype.forEach?function(a,b,c){Array.prototype.forEach.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=u(a)?a.split(""):a,f=0;f<d;f++)f in e&&b.call(c,e[f],f,a)},Ja=Array.prototype.filter?function(a,b,c){return Array.prototype.filter.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=[],f=0,h=u(a)?a.split(""):a,k=0;k<d;k++)if(k in h){var l=h[k];
b.call(c,l,k,a)&&(e[f++]=l)}return e},Ka=Array.prototype.map?function(a,b,c){return Array.prototype.map.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=Array(d),f=u(a)?a.split(""):a,h=0;h<d;h++)h in f&&(e[h]=b.call(c,f[h],h,a));
return e},La=Array.prototype.some?function(a,b,c){return Array.prototype.some.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=u(a)?a.split(""):a,f=0;f<d;f++)if(f in e&&b.call(c,e[f],f,a))return!0;
return!1},Ma=Array.prototype.every?function(a,b,c){return Array.prototype.every.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=u(a)?a.split(""):a,f=0;f<d;f++)if(f in e&&!b.call(c,e[f],f,a))return!1;
return!0};
function Na(a,b,c){b=Oa(a,b,c);return 0>b?null:u(a)?a.charAt(b):a[b]}
function Oa(a,b,c){for(var d=a.length,e=u(a)?a.split(""):a,f=0;f<d;f++)if(f in e&&b.call(c,e[f],f,a))return f;return-1}
function Pa(a,b){return 0<=Ia(a,b)}
function Qa(a,b){Pa(a,b)||a.push(b)}
function Ra(a,b){var c=Ia(a,b),d;(d=0<=c)&&Array.prototype.splice.call(a,c,1);return d}
function Sa(a,b){var c=Oa(a,b,void 0);0<=c&&Array.prototype.splice.call(a,c,1)}
function Ta(a){return Array.prototype.concat.apply(Array.prototype,arguments)}
function Ua(a){var b=a.length;if(0<b){for(var c=Array(b),d=0;d<b;d++)c[d]=a[d];return c}return[]}
function Va(a,b){for(var c=1;c<arguments.length;c++){var d=arguments[c];if(ea(d)){var e=a.length||0,f=d.length||0;a.length=e+f;for(var h=0;h<f;h++)a[e+h]=d[h]}else a.push(d)}}
function Wa(a,b,c,d){return Array.prototype.splice.apply(a,Xa(arguments,1))}
function Xa(a,b,c){return 2>=arguments.length?Array.prototype.slice.call(a,b):Array.prototype.slice.call(a,b,c)}
function Ya(a,b){return a>b?1:a<b?-1:0}
;function Za(a,b,c){for(var d in a)b.call(c,a[d],d,a)}
function $a(a,b,c){var d={},e;for(e in a)b.call(c,a[e],e,a)&&(d[e]=a[e]);return d}
function ab(a){var b=0,c;for(c in a)b++;return b}
function bb(a,b){return cb(a,b)}
function db(a){var b=[],c=0,d;for(d in a)b[c++]=a[d];return b}
function eb(a){var b=[],c=0,d;for(d in a)b[c++]=d;return b}
function fb(a){return null!==a&&"withCredentials"in a}
function cb(a,b){for(var c in a)if(a[c]==b)return!0;return!1}
function gb(a){var b=hb,c;for(c in b)if(a.call(void 0,b[c],c,b))return c}
function ib(a){for(var b in a)return!1;return!0}
function jb(a,b){if(null!==a&&b in a)throw Error('The object already contains the key "'+b+'"');a[b]=!0}
function kb(a){var b={},c;for(c in a)b[c]=a[c];return b}
function lb(a){var b=ca(a);if("object"==b||"array"==b){if(ga(a.clone))return a.clone();var b="array"==b?[]:{},c;for(c in a)b[c]=lb(a[c]);return b}return a}
var mb="constructor hasOwnProperty isPrototypeOf propertyIsEnumerable toLocaleString toString valueOf".split(" ");function nb(a,b){for(var c,d,e=1;e<arguments.length;e++){d=arguments[e];for(c in d)a[c]=d[c];for(var f=0;f<mb.length;f++)c=mb[f],Object.prototype.hasOwnProperty.call(d,c)&&(a[c]=d[c])}}
;var ob;a:{var pb=m.navigator;if(pb){var qb=pb.userAgent;if(qb){ob=qb;break a}}ob=""}function B(a){return-1!=ob.indexOf(a)}
;function rb(){return(B("Chrome")||B("CriOS"))&&!B("Edge")}
;function sb(){this.b=""}
sb.prototype.Nb=!0;sb.prototype.Ib=function(){return this.b};
sb.prototype.toString=function(){return"Const{"+this.b+"}"};
function tb(a){var b=new sb;b.b=a;return b}
;function ub(){this.b="";this.f=vb}
ub.prototype.Nb=!0;ub.prototype.Ib=function(){return this.b};
function wb(a){if(a instanceof ub&&a.constructor===ub&&a.f===vb)return a.b;ca(a);return"type_error:SafeUrl"}
var xb=/^(?:(?:https?|mailto|ftp):|[^&:/?#]*(?:[/?#]|$))/i;function yb(a){if(a instanceof ub)return a;a=a.Nb?a.Ib():String(a);xb.test(a)||(a="about:invalid#zClosurez");return zb(a)}
var vb={};function zb(a){var b=new ub;b.b=a;return b}
zb("about:blank");function Ab(){this.b="";this.f=Bb;this.g=null}
Ab.prototype.Nb=!0;Ab.prototype.Ib=function(){return this.b};
function Cb(a){if(a instanceof Ab&&a.constructor===Ab&&a.f===Bb)return a.b;ca(a);return"type_error:SafeHtml"}
var Bb={};function Db(a,b){var c=new Ab;c.b=a;c.g=b;return c}
Db("<!DOCTYPE html>",0);Db("",0);Db("<br>",0);function Eb(a,b){var c;c=b instanceof ub?b:yb(b);a.href=wb(c)}
;function Fb(a,b,c){a&&(a.dataset?a.dataset[Gb(b)]=c:a.setAttribute("data-"+b,c))}
function C(a,b){return a?a.dataset?a.dataset[Gb(b)]:a.getAttribute("data-"+b):null}
function Hb(a,b){a&&(a.dataset?delete a.dataset[Gb(b)]:a.removeAttribute("data-"+b))}
var Ib={};function Gb(a){return Ib[a]||(Ib[a]=String(a).replace(/\-([a-z])/g,function(a,c){return c.toUpperCase()}))}
;function Jb(a){m.setTimeout(function(){throw a;},0)}
var Kb;
function Lb(){var a=m.MessageChannel;"undefined"===typeof a&&"undefined"!==typeof window&&window.postMessage&&window.addEventListener&&!B("Presto")&&(a=function(){var a=document.createElement("IFRAME");a.style.display="none";a.src="";document.documentElement.appendChild(a);var b=a.contentWindow,a=b.document;a.open();a.write("");a.close();var c="callImmediate"+Math.random(),d="file:"==b.location.protocol?"*":b.location.protocol+"//"+b.location.host,a=w(function(a){if(("*"==d||a.origin==d)&&a.data==
c)this.port1.onmessage()},this);
b.addEventListener("message",a,!1);this.port1={};this.port2={postMessage:function(){b.postMessage(c,d)}}});
if("undefined"!==typeof a&&!B("Trident")&&!B("MSIE")){var b=new a,c={},d=c;b.port1.onmessage=function(){if(p(c.next)){c=c.next;var a=c.dc;c.dc=null;a()}};
return function(a){d.next={dc:a};d=d.next;b.port2.postMessage(0)}}return"undefined"!==typeof document&&"onreadystatechange"in document.createElement("SCRIPT")?function(a){var b=document.createElement("SCRIPT");
b.onreadystatechange=function(){b.onreadystatechange=null;b.parentNode.removeChild(b);b=null;a();a=null};
document.documentElement.appendChild(b)}:function(a){m.setTimeout(a,0)}}
;function Mb(a,b,c){this.h=c;this.g=a;this.i=b;this.f=0;this.b=null}
Mb.prototype.get=function(){var a;0<this.f?(this.f--,a=this.b,this.b=a.next,a.next=null):a=this.g();return a};
function Nb(a,b){a.i(b);a.f<a.h&&(a.f++,b.next=a.b,a.b=b)}
;function Ob(){this.f=this.b=null}
var Qb=new Mb(function(){return new Pb},function(a){a.reset()},100);
Ob.prototype.remove=function(){var a=null;this.b&&(a=this.b,this.b=this.b.next,this.b||(this.f=null),a.next=null);return a};
function Pb(){this.next=this.scope=this.b=null}
Pb.prototype.set=function(a,b){this.b=a;this.scope=b;this.next=null};
Pb.prototype.reset=function(){this.next=this.scope=this.b=null};function Rb(a,b){Sb||Tb();Ub||(Sb(),Ub=!0);var c=Vb,d=Qb.get();d.set(a,b);c.f?c.f.next=d:c.b=d;c.f=d}
var Sb;function Tb(){if(m.Promise&&m.Promise.resolve){var a=m.Promise.resolve(void 0);Sb=function(){a.then(Wb)}}else Sb=function(){var a=Wb;
!ga(m.setImmediate)||m.Window&&m.Window.prototype&&!B("Edge")&&m.Window.prototype.setImmediate==m.setImmediate?(Kb||(Kb=Lb()),Kb(a)):m.setImmediate(a)}}
var Ub=!1,Vb=new Ob;function Wb(){for(var a=null;a=Vb.remove();){try{a.b.call(a.scope)}catch(b){Jb(b)}Nb(Qb,a)}Ub=!1}
;function E(){this.Ga=this.Ga;this.V=this.V}
E.prototype.Ga=!1;E.prototype.isDisposed=function(){return this.Ga};
E.prototype.dispose=function(){this.Ga||(this.Ga=!0,this.w())};
function Xb(a,b){a.Ga?b.call(void 0):(a.V||(a.V=[]),a.V.push(p(void 0)?w(b,void 0):b))}
E.prototype.w=function(){if(this.V)for(;this.V.length;)this.V.shift()()};
function G(a){a&&"function"==typeof a.dispose&&a.dispose()}
function Yb(a){for(var b=0,c=arguments.length;b<c;++b){var d=arguments[b];ea(d)?Yb.apply(null,d):G(d)}}
;function H(a){E.call(this);this.h=1;this.f=[];this.g=0;this.b=[];this.$={};this.i=!!a}
y(H,E);g=H.prototype;g.subscribe=function(a,b,c){var d=this.$[a];d||(d=this.$[a]=[]);var e=this.h;this.b[e]=a;this.b[e+1]=b;this.b[e+2]=c;this.h=e+3;d.push(e);return e};
g.unsubscribe=function(a,b,c){if(a=this.$[a]){var d=this.b;if(a=Na(a,function(a){return d[a+1]==b&&d[a+2]==c}))return this.ha(a)}return!1};
g.ha=function(a){var b=this.b[a];if(b){var c=this.$[b];0!=this.g?(this.f.push(a),this.b[a+1]=t):(c&&Ra(c,a),delete this.b[a],delete this.b[a+1],delete this.b[a+2])}return!!b};
g.u=function(a,b){var c=this.$[a];if(c){for(var d=Array(arguments.length-1),e=1,f=arguments.length;e<f;e++)d[e-1]=arguments[e];if(this.i)for(e=0;e<c.length;e++){var h=c[e];Zb(this.b[h+1],this.b[h+2],d)}else{this.g++;try{for(e=0,f=c.length;e<f;e++)h=c[e],this.b[h+1].apply(this.b[h+2],d)}finally{if(this.g--,0<this.f.length&&0==this.g)for(;c=this.f.pop();)this.ha(c)}}return 0!=e}return!1};
function Zb(a,b,c){Rb(function(){a.apply(b,c)})}
g.clear=function(a){if(a){var b=this.$[a];b&&(A(b,this.ha,this),delete this.$[a])}else this.b.length=0,this.$={}};
g.N=function(a){if(a){var b=this.$[a];return b?b.length:0}a=0;for(b in this.$)a+=this.N(b);return a};
g.w=function(){H.A.w.call(this);this.clear();this.f.length=0};var $b=window.yt&&window.yt.config_||window.ytcfg&&window.ytcfg.data_||{};q("yt.config_",$b,void 0);q("yt.tokens_",window.yt&&window.yt.tokens_||{},void 0);var ac=window.yt&&window.yt.msgs_||r("window.ytcfg.msgs")||{};q("yt.msgs_",ac,void 0);function bc(a){cc($b,arguments)}
function I(a,b){return a in $b?$b[a]:b}
function J(a,b){ga(a)&&(a=dc(a));return window.setTimeout(a,b)}
function K(a){window.clearTimeout(a)}
function dc(a){return a&&window.yterr?function(){try{return a.apply(this,arguments)}catch(b){throw ec(b),b;}}:a}
function ec(a,b){var c=r("yt.logging.errors.log");c?c(a,b,void 0,void 0,void 0):(c=I("ERRORS",[]),c.push([a,b,void 0,void 0,void 0]),bc("ERRORS",c))}
function fc(){var a={},b="FLASH_UPGRADE"in ac?ac.FLASH_UPGRADE:'You need to upgrade your Adobe Flash Player to watchthis video. <br> <a href="http://get.adobe.com/flashplayer/">Download it from Adobe.</a>';if(b)for(var c in a)b=b.replace(new RegExp("\\$"+c,"gi"),function(){return a[c]});
return b}
function cc(a,b){if(1<b.length){var c=b[0];a[c]=b[1]}else{var d=b[0];for(c in d)a[c]=d[c]}}
var gc=window.performance&&window.performance.timing&&window.performance.now&&window.__yt_experimental_now?function(){return window.performance.timing.navigationStart+window.performance.now()}:function(){return(new Date).getTime()},hc="Microsoft Internet Explorer"==navigator.appName;var ic=r("yt.pubsub.instance_")||new H;H.prototype.subscribe=H.prototype.subscribe;H.prototype.unsubscribeByKey=H.prototype.ha;H.prototype.publish=H.prototype.u;H.prototype.clear=H.prototype.clear;q("yt.pubsub.instance_",ic,void 0);var jc=r("yt.pubsub.subscribedKeys_")||{};q("yt.pubsub.subscribedKeys_",jc,void 0);var kc=r("yt.pubsub.topicToKeys_")||{};q("yt.pubsub.topicToKeys_",kc,void 0);var lc=r("yt.pubsub.isSynchronous_")||{};q("yt.pubsub.isSynchronous_",lc,void 0);
var mc=r("yt.pubsub.skipSubId_")||null;q("yt.pubsub.skipSubId_",mc,void 0);function nc(a,b,c){var d=oc();if(d){var e=d.subscribe(a,function(){if(!mc||mc!=e){var d=arguments,h;h=function(){jc[e]&&b.apply(c||window,d)};
try{lc[a]?h():J(h,0)}catch(k){ec(k)}}},c);
jc[e]=!0;kc[a]||(kc[a]=[]);kc[a].push(e);return e}return 0}
function pc(a){var b=oc();b&&("number"==typeof a?a=[a]:"string"==typeof a&&(a=[parseInt(a,10)]),A(a,function(a){b.unsubscribeByKey(a);delete jc[a]}))}
function qc(a,b){var c=oc();return c?c.publish.apply(c,arguments):!1}
function rc(a,b){lc[a]=!0;var c=oc();c&&c.publish.apply(c,arguments);lc[a]=!1}
function sc(a){kc[a]&&(a=kc[a],A(a,function(a){jc[a]&&delete jc[a]}),a.length=0)}
function tc(a){var b=oc();if(b)if(b.clear(a),a)sc(a);else for(var c in kc)sc(c)}
function oc(){return r("yt.pubsub.instance_")}
;function uc(a,b){if(window.spf){var c="";if(a){var d=a.indexOf("jsbin/"),e=a.lastIndexOf(".js"),f=d+6;-1<d&&-1<e&&e>f&&(c=a.substring(f,e),c=c.replace(vc,""),c=c.replace(wc,""),c=c.replace("debug-",""),c=c.replace("tracing-",""))}spf.script.load(a,c,b)}else xc(a,b)}
function xc(a,b){var c=yc(a),d=document.getElementById(c),e=d&&C(d,"loaded"),f=d&&!e;if(e)b&&b();else{if(b){var e=nc(c,b),h=""+ia(b);zc[h]=e}f||(d=Ac(a,c,function(){C(d,"loaded")||(Fb(d,"loaded","true"),qc(c),J(oa(tc,c),0))}))}}
function Ac(a,b,c){var d=document.createElement("script");d.id=b;d.onload=function(){c&&setTimeout(c,0)};
d.onreadystatechange=function(){switch(d.readyState){case "loaded":case "complete":d.onload()}};
d.src=a;a=document.getElementsByTagName("head")[0]||document.body;a.insertBefore(d,a.firstChild);return d}
function Bc(a,b){if(a&&b){var c=""+ia(b);(c=zc[c])&&pc(c)}}
function yc(a){var b=document.createElement("a");Eb(b,a);a=b.href.replace(/^[a-zA-Z]+:\/\//,"//");return"js-"+Ha(a)}
var vc=/\.vflset|-vfl[a-zA-Z0-9_+=-]+/,wc=/-[a-zA-Z]{2,3}_[a-zA-Z]{2,3}(?=(\/|$))/,zc={};var Cc=null;function Dc(){var a=I("BG_I",null),b=I("BG_IU",null),c=I("BG_P",void 0);b?uc(b,function(){Cc=new botguard.bg(c)}):a&&(eval(a),Cc=new botguard.bg(c))}
function Ec(){return null!=Cc}
function Fc(){return Cc?Cc.invoke():null}
;function Gc(a,b){return Db(b,null)}
;var Hc="StopIteration"in m?m.StopIteration:{message:"StopIteration",stack:""};function Ic(){}
Ic.prototype.next=function(){throw Hc;};
Ic.prototype.ma=function(){return this};
function Jc(a){if(a instanceof Ic)return a;if("function"==typeof a.ma)return a.ma(!1);if(ea(a)){var b=0,c=new Ic;c.next=function(){for(;;){if(b>=a.length)throw Hc;if(b in a)return a[b++];b++}};
return c}throw Error("Not implemented");}
function Kc(a,b,c){if(ea(a))try{A(a,b,c)}catch(d){if(d!==Hc)throw d;}else{a=Jc(a);try{for(;;)b.call(c,a.next(),void 0,a)}catch(d){if(d!==Hc)throw d;}}}
function Lc(a){if(ea(a))return Ua(a);a=Jc(a);var b=[];Kc(a,function(a){b.push(a)});
return b}
;function Mc(a,b){this.f={};this.b=[];this.wa=this.g=0;var c=arguments.length;if(1<c){if(c%2)throw Error("Uneven number of arguments");for(var d=0;d<c;d+=2)this.set(arguments[d],arguments[d+1])}else if(a){a instanceof Mc?(c=a.ia(),d=a.O()):(c=eb(a),d=db(a));for(var e=0;e<c.length;e++)this.set(c[e],d[e])}}
g=Mc.prototype;g.N=function(){return this.g};
g.O=function(){Nc(this);for(var a=[],b=0;b<this.b.length;b++)a.push(this.f[this.b[b]]);return a};
g.ia=function(){Nc(this);return this.b.concat()};
g.Sa=function(a){for(var b=0;b<this.b.length;b++){var c=this.b[b];if(Oc(this.f,c)&&this.f[c]==a)return!0}return!1};
g.equals=function(a,b){if(this===a)return!0;if(this.g!=a.N())return!1;var c=b||Pc;Nc(this);for(var d,e=0;d=this.b[e];e++)if(!c(this.get(d),a.get(d)))return!1;return!0};
function Pc(a,b){return a===b}
g.isEmpty=function(){return 0==this.g};
g.clear=function(){this.f={};this.wa=this.g=this.b.length=0};
g.remove=function(a){return Oc(this.f,a)?(delete this.f[a],this.g--,this.wa++,this.b.length>2*this.g&&Nc(this),!0):!1};
function Nc(a){if(a.g!=a.b.length){for(var b=0,c=0;b<a.b.length;){var d=a.b[b];Oc(a.f,d)&&(a.b[c++]=d);b++}a.b.length=c}if(a.g!=a.b.length){for(var e={},c=b=0;b<a.b.length;)d=a.b[b],Oc(e,d)||(a.b[c++]=d,e[d]=1),b++;a.b.length=c}}
g.get=function(a,b){return Oc(this.f,a)?this.f[a]:b};
g.set=function(a,b){Oc(this.f,a)||(this.g++,this.b.push(a),this.wa++);this.f[a]=b};
g.forEach=function(a,b){for(var c=this.ia(),d=0;d<c.length;d++){var e=c[d],f=this.get(e);a.call(b,f,e,this)}};
g.clone=function(){return new Mc(this)};
g.ma=function(a){Nc(this);var b=0,c=this.wa,d=this,e=new Ic;e.next=function(){if(c!=d.wa)throw Error("The map has changed since the iterator was created");if(b>=d.b.length)throw Hc;var e=d.b[b++];return a?e:d.f[e]};
return e};
function Oc(a,b){return Object.prototype.hasOwnProperty.call(a,b)}
;function Qc(a){return a.N&&"function"==typeof a.N?a.N():ea(a)||u(a)?a.length:ab(a)}
function Rc(a){if(a.O&&"function"==typeof a.O)return a.O();if(u(a))return a.split("");if(ea(a)){for(var b=[],c=a.length,d=0;d<c;d++)b.push(a[d]);return b}return db(a)}
function Sc(a){if(a.ia&&"function"==typeof a.ia)return a.ia();if(!a.O||"function"!=typeof a.O){if(ea(a)||u(a)){var b=[];a=a.length;for(var c=0;c<a;c++)b.push(c);return b}return eb(a)}}
function Tc(a,b,c){if(a.forEach&&"function"==typeof a.forEach)a.forEach(b,c);else if(ea(a)||u(a))A(a,b,c);else for(var d=Sc(a),e=Rc(a),f=e.length,h=0;h<f;h++)b.call(c,e[h],d&&d[h],a)}
function Uc(a,b){if("function"==typeof a.every)return a.every(b,void 0);if(ea(a)||u(a))return Ma(a,b,void 0);for(var c=Sc(a),d=Rc(a),e=d.length,f=0;f<e;f++)if(!b.call(void 0,d[f],c&&c[f],a))return!1;return!0}
;function Vc(a){this.b=new Mc;a&&Wc(this,a)}
function Xc(a){var b=typeof a;return"object"==b&&a||"function"==b?"o"+ia(a):b.substr(0,1)+a}
g=Vc.prototype;g.N=function(){return this.b.N()};
function Wc(a,b){for(var c=Rc(b),d=c.length,e=0;e<d;e++){var f=c[e];a.b.set(Xc(f),f)}}
g.remove=function(a){return this.b.remove(Xc(a))};
g.clear=function(){this.b.clear()};
g.isEmpty=function(){return this.b.isEmpty()};
g.contains=function(a){a=Xc(a);return Oc(this.b.f,a)};
g.O=function(){return this.b.O()};
g.clone=function(){return new Vc(this)};
g.equals=function(a){return this.N()==Qc(a)&&Yc(this,a)};
function Yc(a,b){var c=Qc(b);if(a.N()>c)return!1;!(b instanceof Vc)&&5<c&&(b=new Vc(b));return Uc(a,function(a){var c=b;return c.contains&&"function"==typeof c.contains?c.contains(a):c.Sa&&"function"==typeof c.Sa?c.Sa(a):ea(c)||u(c)?Pa(c,a):cb(c,a)})}
g.ma=function(){return this.b.ma(!1)};function Zc(){return B("iPhone")&&!B("iPod")&&!B("iPad")}
;var $c=B("Opera"),L=B("Trident")||B("MSIE"),ad=B("Edge"),bd=B("Gecko")&&!(-1!=ob.toLowerCase().indexOf("webkit")&&!B("Edge"))&&!(B("Trident")||B("MSIE"))&&!B("Edge"),cd=-1!=ob.toLowerCase().indexOf("webkit")&&!B("Edge"),dd=B("Macintosh"),ed=B("Windows");function fd(){var a=m.document;return a?a.documentMode:void 0}
var gd;a:{var hd="",id=function(){var a=ob;if(bd)return/rv\:([^\);]+)(\)|;)/.exec(a);if(ad)return/Edge\/([\d\.]+)/.exec(a);if(L)return/\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);if(cd)return/WebKit\/(\S+)/.exec(a);if($c)return/(?:Version)[ \/]?(\S+)/.exec(a)}();
id&&(hd=id?id[1]:"");if(L){var jd=fd();if(null!=jd&&jd>parseFloat(hd)){gd=String(jd);break a}}gd=hd}var kd=gd,ld={};function md(a){return ld[a]||(ld[a]=0<=Fa(kd,a))}
function nd(a){return Number(od)>=a}
var pd=m.document,od=pd&&L?fd()||("CSS1Compat"==pd.compatMode?parseInt(kd,10):5):void 0;function qd(a){a=String(a);if(/^\s*$/.test(a)?0:/^[\],:{}\s\u2028\u2029]*$/.test(a.replace(/\\["\\\/bfnrtu]/g,"@").replace(/(?:"[^"\\\n\r\u2028\u2029\x00-\x08\x0a-\x1f]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)[\s\u2028\u2029]*(?=:|,|]|}|$)/g,"]").replace(/(?:^|:|,)(?:[\s\u2028\u2029]*\[)+/g,"")))try{return eval("("+a+")")}catch(b){}throw Error("Invalid JSON string: "+a);}
function rd(a){return eval("("+a+")")}
function M(a){return sd(new td(void 0),a)}
function td(a){this.b=a}
function sd(a,b){var c=[];ud(a,b,c);return c.join("")}
function ud(a,b,c){if(null==b)c.push("null");else{if("object"==typeof b){if(da(b)){var d=b;b=d.length;c.push("[");for(var e="",f=0;f<b;f++)c.push(e),e=d[f],ud(a,a.b?a.b.call(d,String(f),e):e,c),e=",";c.push("]");return}if(b instanceof String||b instanceof Number||b instanceof Boolean)b=b.valueOf();else{c.push("{");f="";for(d in b)Object.prototype.hasOwnProperty.call(b,d)&&(e=b[d],"function"!=typeof e&&(c.push(f),vd(d,c),c.push(":"),ud(a,a.b?a.b.call(b,d,e):e,c),f=","));c.push("}");return}}switch(typeof b){case "string":vd(b,
c);break;case "number":c.push(isFinite(b)&&!isNaN(b)?String(b):"null");break;case "boolean":c.push(String(b));break;case "function":c.push("null");break;default:throw Error("Unknown type: "+typeof b);}}}
var wd={'"':'\\"',"\\":"\\\\","/":"\\/","\b":"\\b","\f":"\\f","\n":"\\n","\r":"\\r","\t":"\\t","\x0B":"\\u000b"},xd=/\uffff/.test("\uffff")?/[\\\"\x00-\x1f\x7f-\uffff]/g:/[\\\"\x00-\x1f\x7f-\xff]/g;function vd(a,b){b.push('"',a.replace(xd,function(a){var b=wd[a];b||(b="\\u"+(a.charCodeAt(0)|65536).toString(16).substr(1),wd[a]=b);return b}),'"')}
;var yd=/^(?:([^:/?#.]+):)?(?:\/\/(?:([^/?#]*)@)?([^/#?]*?)(?::([0-9]+))?(?=[/#?]|$))?([^?#]+)?(?:\?([^#]*))?(?:#(.*))?$/;function zd(a){return(a=a.match(yd)[3]||null)?decodeURI(a):a}
function Ad(a,b){if(a)for(var c=a.split("&"),d=0;d<c.length;d++){var e=c[d].indexOf("="),f=null,h=null;0<=e?(f=c[d].substring(0,e),h=c[d].substring(e+1)):f=c[d];b(f,h?sa(h):"")}}
function Bd(a){if(a[1]){var b=a[0],c=b.indexOf("#");0<=c&&(a.push(b.substr(c)),a[0]=b=b.substr(0,c));c=b.indexOf("?");0>c?a[1]="?":c==b.length-1&&(a[1]=void 0)}return a.join("")}
function Cd(a,b,c){if(da(b))for(var d=0;d<b.length;d++)Cd(a,String(b[d]),c);else null!=b&&c.push("&",a,""===b?"":"=",encodeURIComponent(String(b)))}
function Dd(a,b,c){for(c=c||0;c<b.length;c+=2)Cd(b[c],b[c+1],a);return a}
function Ed(a,b){for(var c in b)Cd(c,b[c],a);return a}
function Fd(a){a=Ed([],a);a[0]="";return a.join("")}
function Gd(a,b){return Bd(2==arguments.length?Dd([a],arguments[1],0):Dd([a],arguments,1))}
function Hd(a,b){return Bd(Ed([a],b))}
;function Id(a){"?"==a.charAt(0)&&(a=a.substr(1));a=a.split("&");for(var b={},c=0,d=a.length;c<d;c++){var e=a[c].split("=");if(1==e.length&&e[0]||2==e.length){var f=sa(e[0]||""),e=sa(e[1]||"");f in b?da(b[f])?Va(b[f],e):b[f]=[b[f],e]:b[f]=e}}return b}
function Jd(a,b){var c=a.split("#",2);a=c[0];var c=1<c.length?"#"+c[1]:"",d=a.split("?",2);a=d[0];var d=Id(d[1]||""),e;for(e in b)d[e]=b[e];return Hd(a,d)+c}
function Kd(a){a=zd(a);a=null===a?null:a.split(".").reverse();return(null===a?!1:"com"==a[0]&&a[1].match(/^youtube(?:-nocookie)?$/)?!0:!1)||(null===a?!1:"google"==a[1]?!0:"google"==a[2]?"au"==a[0]&&"com"==a[1]?!0:"uk"==a[0]&&"co"==a[1]?!0:!1:!1)}
;var Ld=null;"undefined"!=typeof XMLHttpRequest?Ld=function(){return new XMLHttpRequest}:"undefined"!=typeof ActiveXObject&&(Ld=function(){return new ActiveXObject("Microsoft.XMLHTTP")});
function Md(a){switch(a&&"status"in a?a.status:-1){case 200:case 201:case 202:case 203:case 204:case 205:case 206:case 304:return!0;default:return!1}}
;function Nd(a,b,c,d,e,f,h){function k(){4==(l&&"readyState"in l?l.readyState:0)&&b&&dc(b)(l)}
var l=Ld&&Ld();if(!("open"in l))return null;"onloadend"in l?l.addEventListener("loadend",k,!1):l.onreadystatechange=k;c=(c||"GET").toUpperCase();d=d||"";l.open(c,a,!0);f&&(l.responseType=f);h&&(l.withCredentials=!0);f="POST"==c;if(e=Od(a,e))for(var n in e)l.setRequestHeader(n,e[n]),"content-type"==n.toLowerCase()&&(f=!1);f&&l.setRequestHeader("Content-Type","application/x-www-form-urlencoded");l.send(d);return l}
function Od(a,b){b=b||{};var c;c||(c=window.location.href);var d=a.match(yd)[1]||null,e=zd(a);d&&e?(d=c,c=a.match(yd),d=d.match(yd),c=c[3]==d[3]&&c[1]==d[1]&&c[4]==d[4]):c=e?zd(c)==e&&(Number(c.match(yd)[4]||null)||null)==(Number(a.match(yd)[4]||null)||null):!0;for(var f in Pd){if((e=d=I(Pd[f]))&&!(e=c)){var e=f,h=I("CORS_HEADER_WHITELIST")||{},k=zd(a);e=k?(h=h[k])?Pa(h,e):!1:!0}e&&(b[f]=d)}return b}
function Qd(a,b){var c=I("XSRF_FIELD_NAME",void 0),d;b.headers&&(d=b.headers["Content-Type"]);return!b.Te&&(!zd(a)||b.withCredentials||zd(a)==document.location.hostname)&&"POST"==b.method&&(!d||"application/x-www-form-urlencoded"==d)&&!(b.J&&b.J[c])}
function Rd(a,b){var c=b.format||"JSON";b.Ue&&(a=document.location.protocol+"//"+document.location.hostname+(document.location.port?":"+document.location.port:"")+a);var d=I("XSRF_FIELD_NAME",void 0),e=I("XSRF_TOKEN",void 0),f=b.Ub;f&&(f[d]&&delete f[d],a=Jd(a,f||{}));var h=b.postBody||"",f=b.J;Qd(a,b)&&(f||(f={}),f[d]=e);f&&u(h)&&(d=Id(h),nb(d,f),h=b.Bc&&"JSON"==b.Bc?JSON.stringify(d):Fd(d));var k=!1,l,n=Nd(a,function(a){if(!k){k=!0;l&&K(l);var d=Md(a),e=null;if(d||400<=a.status&&500>a.status)e=
Sd(c,a,b.Se);if(d)a:{switch(c){case "XML":d=0==parseInt(e&&e.return_code,10);break a;case "RAW":d=!0;break a}d=!!e}var e=e||{},f=b.context||m;d?b.Z&&b.Z.call(f,a,e):b.onError&&b.onError.call(f,a,e);b.Qb&&b.Qb.call(f,a,e)}},b.method,h,b.headers,b.responseType,b.withCredentials);
b.Ea&&0<b.timeout&&(l=J(function(){k||(k=!0,n.abort(),K(l),b.Ea.call(b.context||m,n))},b.timeout));
return n}
function Sd(a,b,c){var d=null;switch(a){case "JSON":a=b.responseText;b=b.getResponseHeader("Content-Type")||"";a&&0<=b.indexOf("json")&&(d=rd(a));break;case "XML":if(b=(b=b.responseXML)?Td(b):null)d={},A(b.getElementsByTagName("*"),function(a){d[a.tagName]=Ud(a)})}c&&Vd(d);
return d}
function Vd(a){if(ha(a))for(var b in a){var c;(c="html_content"==b)||(c=b.length-5,c=0<=c&&b.indexOf("_html",c)==c);c?a[b]=Gc(tb("HTML that is escaped and sanitized server-side and passed through yt.net.ajax"),a[b]):Vd(a[b])}}
function Td(a){return a?(a=("responseXML"in a?a.responseXML:a).getElementsByTagName("root"))&&0<a.length?a[0]:null:null}
function Ud(a){var b="";A(a.childNodes,function(a){b+=a.nodeValue});
return b}
var Pd={"X-YouTube-Client-Name":"INNERTUBE_CONTEXT_CLIENT_NAME","X-YouTube-Client-Version":"INNERTUBE_CONTEXT_CLIENT_VERSION","X-Youtube-Identity-Token":"XSRF_TOKEN","X-YouTube-Page-CL":"PAGE_CL","X-YouTube-Page-Label":"PAGE_BUILD_LABEL","X-YouTube-Variants-Checksum":"VARIANTS_CHECKSUM"};var Wd={},Xd=0;function Yd(a,b){isNaN(b)&&(b=void 0);var c=r("yt.scheduler.instance.addJob");return c?c(a,0,b):void 0===b?(a(),NaN):J(a,b||0)}
;var Zd=[],$d=!1;function ae(){function a(){$d=!0;"google_ad_status"in window?bc("DCLKSTAT",1):bc("DCLKSTAT",2)}
uc("//static.doubleclick.net/instream/ad_status.js",a);Zd.push(Yd(function(){$d||"google_ad_status"in window||(Bc("//static.doubleclick.net/instream/ad_status.js",a),bc("DCLKSTAT",3))},5E3))}
function be(){return parseInt(I("DCLKSTAT",0),10)}
;function ce(a){if(a.classList)return a.classList;a=a.className;return u(a)&&a.match(/\S+/g)||[]}
function de(a,b){return a.classList?a.classList.contains(b):Pa(ce(a),b)}
function ee(a,b){a.classList?a.classList.add(b):de(a,b)||(a.className+=0<a.className.length?" "+b:b)}
function fe(a,b){a.classList?a.classList.remove(b):de(a,b)&&(a.className=Ja(ce(a),function(a){return a!=b}).join(" "))}
function ge(a,b,c){c?ee(a,b):fe(a,b)}
;function he(a,b){this.x=p(a)?a:0;this.y=p(b)?b:0}
he.prototype.clone=function(){return new he(this.x,this.y)};
he.prototype.ceil=function(){this.x=Math.ceil(this.x);this.y=Math.ceil(this.y);return this};
he.prototype.floor=function(){this.x=Math.floor(this.x);this.y=Math.floor(this.y);return this};
he.prototype.round=function(){this.x=Math.round(this.x);this.y=Math.round(this.y);return this};function ie(a,b){this.width=a;this.height=b}
g=ie.prototype;g.clone=function(){return new ie(this.width,this.height)};
g.Bb=function(){return this.width*this.height};
g.aspectRatio=function(){return this.width/this.height};
g.isEmpty=function(){return!this.Bb()};
g.ceil=function(){this.width=Math.ceil(this.width);this.height=Math.ceil(this.height);return this};
g.floor=function(){this.width=Math.floor(this.width);this.height=Math.floor(this.height);return this};
g.round=function(){this.width=Math.round(this.width);this.height=Math.round(this.height);return this};!bd&&!L||L&&nd(9)||bd&&md("1.9.1");var je=L&&!md("9");function ke(a){return a?new me(ne(a)):qa||(qa=new me)}
function oe(a){return u(a)?document.getElementById(a):a}
function pe(a){var b=document;return u(a)?b.getElementById(a):a}
function qe(a){var b=document;return b.querySelectorAll&&b.querySelector?b.querySelectorAll("."+a):re(a,void 0)}
function re(a,b){var c,d,e,f;c=document;c=b||c;if(c.querySelectorAll&&c.querySelector&&a)return c.querySelectorAll(""+(a?"."+a:""));if(a&&c.getElementsByClassName){var h=c.getElementsByClassName(a);return h}h=c.getElementsByTagName("*");if(a){f={};for(d=e=0;c=h[d];d++){var k=c.className;"function"==typeof k.split&&Pa(k.split(/\s+/),a)&&(f[e++]=c)}f.length=e;return f}return h}
function se(a){a=a.document;a=te(a)?a.documentElement:a.body;return new ie(a.clientWidth,a.clientHeight)}
function ue(a){var b=a.scrollingElement?a.scrollingElement:!cd&&te(a)?a.documentElement:a.body||a.documentElement;a=a.parentWindow||a.defaultView;return L&&md("10")&&a.pageYOffset!=b.scrollTop?new he(b.scrollLeft,b.scrollTop):new he(a.pageXOffset||b.scrollLeft,a.pageYOffset||b.scrollTop)}
function te(a){return"CSS1Compat"==a.compatMode}
function ve(a){for(var b;b=a.firstChild;)a.removeChild(b)}
function we(a){if(!a)return null;if(a.firstChild)return a.firstChild;for(;a&&!a.nextSibling;)a=a.parentNode;return a?a.nextSibling:null}
function xe(a){if(!a)return null;if(!a.previousSibling)return a.parentNode;for(a=a.previousSibling;a&&a.lastChild;)a=a.lastChild;return a}
function ne(a){return 9==a.nodeType?a:a.ownerDocument||a.document}
function ye(a,b){if("textContent"in a)a.textContent=b;else if(3==a.nodeType)a.data=b;else if(a.firstChild&&3==a.firstChild.nodeType){for(;a.lastChild!=a.firstChild;)a.removeChild(a.lastChild);a.firstChild.data=b}else{ve(a);var c=ne(a);a.appendChild(c.createTextNode(String(b)))}}
var ze={SCRIPT:1,STYLE:1,HEAD:1,IFRAME:1,OBJECT:1},Ae={IMG:" ",BR:"\n"};function Be(a){if(je&&null!==a&&"innerText"in a)a=a.innerText.replace(/(\r\n|\r|\n)/g,"\n");else{var b=[];Ce(a,b,!0);a=b.join("")}a=a.replace(/ \xAD /g," ").replace(/\xAD/g,"");a=a.replace(/\u200B/g,"");je||(a=a.replace(/ +/g," "));" "!=a&&(a=a.replace(/^\s*/,""));return a}
function Ce(a,b,c){if(!(a.nodeName in ze))if(3==a.nodeType)c?b.push(String(a.nodeValue).replace(/(\r\n|\r|\n)/g,"")):b.push(a.nodeValue);else if(a.nodeName in Ae)b.push(Ae[a.nodeName]);else for(a=a.firstChild;a;)Ce(a,b,c),a=a.nextSibling}
function De(a){var b=Ee.Tc;return b?Fe(a,function(a){return!b||u(a.className)&&Pa(a.className.split(/\s+/),b)},!0,void 0):null}
function Fe(a,b,c,d){c||(a=a.parentNode);for(c=0;a&&(null==d||c<=d);){if(b(a))return a;a=a.parentNode;c++}return null}
function me(a){this.b=a||m.document||document}
me.prototype.createElement=function(a){return this.b.createElement(a)};
me.prototype.appendChild=function(a,b){a.appendChild(b)};
me.prototype.isElement=function(a){return ha(a)&&1==a.nodeType};
me.prototype.contains=function(a,b){if(!a||!b)return!1;if(a.contains&&1==b.nodeType)return a==b||a.contains(b);if("undefined"!=typeof a.compareDocumentPosition)return a==b||!!(a.compareDocumentPosition(b)&16);for(;b&&a!=b;)b=b.parentNode;return b==a};var Ge=cd?"webkit":bd?"moz":L?"ms":$c?"o":"",He=r("yt.dom.getNextId_");if(!He){He=function(){return++Ie};
q("yt.dom.getNextId_",He,void 0);var Ie=0}function Je(){var a=document,b;La(["fullscreenElement","fullScreenElement"],function(c){c in a?b=a[c]:(c=Ge+c.charAt(0).toUpperCase()+c.substr(1),b=c in a?a[c]:void 0);return!!b});
return b}
;function Ke(a){this.type="";this.state=this.source=this.data=this.currentTarget=this.relatedTarget=this.target=null;this.charCode=this.keyCode=0;this.shiftKey=this.ctrlKey=this.altKey=!1;this.clientY=this.clientX=0;this.changedTouches=null;if(a=a||window.event){this.event=a;for(var b in a)b in Le||(this[b]=a[b]);(b=a.target||a.srcElement)&&3==b.nodeType&&(b=b.parentNode);this.target=b;if(b=a.relatedTarget)try{b=b.nodeName?b:null}catch(c){b=null}else"mouseover"==this.type?b=a.fromElement:"mouseout"==
this.type&&(b=a.toElement);this.relatedTarget=b;this.clientX=void 0!=a.clientX?a.clientX:a.pageX;this.clientY=void 0!=a.clientY?a.clientY:a.pageY;this.keyCode=a.keyCode?a.keyCode:a.which;this.charCode=a.charCode||("keypress"==this.type?this.keyCode:0);this.altKey=a.altKey;this.ctrlKey=a.ctrlKey;this.shiftKey=a.shiftKey}}
Ke.prototype.preventDefault=function(){this.event&&(this.event.returnValue=!1,this.event.preventDefault&&this.event.preventDefault())};
Ke.prototype.stopPropagation=function(){this.event&&(this.event.cancelBubble=!0,this.event.stopPropagation&&this.event.stopPropagation())};
Ke.prototype.stopImmediatePropagation=function(){this.event&&(this.event.cancelBubble=!0,this.event.stopImmediatePropagation&&this.event.stopImmediatePropagation())};
var Le={stopImmediatePropagation:1,stopPropagation:1,preventMouseEvent:1,preventManipulation:1,preventDefault:1,layerX:1,layerY:1,scale:1,rotation:1,webkitMovementX:1,webkitMovementY:1};var hb=r("yt.events.listeners_")||{};q("yt.events.listeners_",hb,void 0);var Me=r("yt.events.counter_")||{count:0};q("yt.events.counter_",Me,void 0);function Ne(a,b,c,d){a.addEventListener&&("mouseenter"!=b||"onmouseenter"in document?"mouseleave"!=b||"onmouseenter"in document?"mousewheel"==b&&"MozBoxSizing"in document.documentElement.style&&(b="MozMousePixelScroll"):b="mouseout":b="mouseover");return gb(function(e){return e[0]==a&&e[1]==b&&e[2]==c&&e[4]==!!d})}
function N(a,b,c,d){if(!a||!a.addEventListener&&!a.attachEvent)return"";d=!!d;var e=Ne(a,b,c,d);if(e)return e;var e=++Me.count+"",f=!("mouseenter"!=b&&"mouseleave"!=b||!a.addEventListener||"onmouseenter"in document),h;h=f?function(d){d=new Ke(d);if(!Fe(d.relatedTarget,function(b){return b==a},!0))return d.currentTarget=a,d.type=b,c.call(a,d)}:function(b){b=new Ke(b);
b.currentTarget=a;return c.call(a,b)};
h=dc(h);a.addEventListener?("mouseenter"==b&&f?b="mouseover":"mouseleave"==b&&f?b="mouseout":"mousewheel"==b&&"MozBoxSizing"in document.documentElement.style&&(b="MozMousePixelScroll"),a.addEventListener(b,h,d)):a.attachEvent("on"+b,h);hb[e]=[a,b,c,h,d];return e}
function Oe(a){a&&("string"==typeof a&&(a=[a]),A(a,function(a){if(a in hb){var c=hb[a],d=c[0],e=c[1],f=c[3],c=c[4];d.removeEventListener?d.removeEventListener(e,f,c):d.detachEvent&&d.detachEvent("on"+e,f);delete hb[a]}}))}
;function Pe(){if(null==r("_lact",window)){var a=parseInt(I("LACT"),10),a=isFinite(a)?x()-Math.max(a,0):-1;q("_lact",a,window);-1==a&&Qe();N(document,"keydown",Qe);N(document,"keyup",Qe);N(document,"mousedown",Qe);N(document,"mouseup",Qe);nc("page-mouse",Qe);nc("page-scroll",Qe);nc("page-resize",Qe)}}
function Qe(){null==r("_lact",window)&&(Pe(),r("_lact",window));var a=x();q("_lact",a,window);qc("USER_ACTIVE")}
function Re(){var a=r("_lact",window);return null==a?-1:Math.max(x()-a,0)}
;function Se(){}
;function Te(a){this.b=a||{cookie:""}}
var Ue=/\s*;\s*/;g=Te.prototype;g.isEnabled=function(){return navigator.cookieEnabled};
g.set=function(a,b,c,d,e,f){if(/[;=\s]/.test(a))throw Error('Invalid cookie name "'+a+'"');if(/[;\r\n]/.test(b))throw Error('Invalid cookie value "'+b+'"');p(c)||(c=-1);e=e?";domain="+e:"";d=d?";path="+d:"";f=f?";secure":"";c=0>c?"":0==c?";expires="+(new Date(1970,1,1)).toUTCString():";expires="+(new Date(x()+1E3*c)).toUTCString();this.b.cookie=a+"="+b+e+d+c+f};
g.get=function(a,b){for(var c=a+"=",d=(this.b.cookie||"").split(Ue),e=0,f;f=d[e];e++){if(0==f.lastIndexOf(c,0))return f.substr(c.length);if(f==a)return""}return b};
g.remove=function(a,b,c){var d=p(this.get(a));this.set(a,"",0,b,c);return d};
g.ia=function(){return Ve(this).keys};
g.O=function(){return Ve(this).values};
g.isEmpty=function(){return!this.b.cookie};
g.N=function(){return this.b.cookie?(this.b.cookie||"").split(Ue).length:0};
g.Sa=function(a){for(var b=Ve(this).values,c=0;c<b.length;c++)if(b[c]==a)return!0;return!1};
g.clear=function(){for(var a=Ve(this).keys,b=a.length-1;0<=b;b--)this.remove(a[b])};
function Ve(a){a=(a.b.cookie||"").split(Ue);for(var b=[],c=[],d,e,f=0;e=a[f];f++)d=e.indexOf("="),-1==d?(b.push(""),c.push(e)):(b.push(e.substring(0,d)),c.push(e.substring(d+1)));return{keys:b,values:c}}
var We=new Te("undefined"==typeof document?null:document);We.f=3950;function Xe(a,b,c){We.set(""+a,b,c,"/","youtube.com")}
;function Ye(a,b,c){var d=I("EVENT_ID");d&&(b||(b={}),b.ei||(b.ei=d));if(b){var d=I("VALID_SESSION_TEMPDATA_DOMAINS",[]),e=zd(window.location.href);e&&d.push(e);e=zd(a);if(Pa(d,e)||!e&&0==a.lastIndexOf("/",0)){var f=a.match(yd),d=f[5],e=f[6],f=f[7],h="";d&&(h+=d);e&&(h+="?"+e);f&&(h+="#"+f);d=h;e=d.indexOf("#");if(d=0>e?d:d.substr(0,e))e=I("ST_BASE36",!0),f=I("ST_SHORT",!0)?"ST-":"s_tempdata-",d=f=e?f+Ha(d).toString(36):f+Ha(d),e=b?Fd(b):"",Xe(d,e,5),b&&(b=b.itct||b.ved,d=r("yt.logging.screenreporter.storeParentElement"),
b&&d&&d(new Se))}}if(c)return!1;(window.ytspf||{}).enabled?spf.navigate(a):(c=window.location,a=Hd(a,{})+"",a=a instanceof ub?a:yb(a),c.href=wb(a));return!0}
;function Ze(a){a=a||{};this.url=a.url||"";this.urlV9As2=a.url_v9as2||"";this.args=a.args||kb($e);this.assets=a.assets||{};this.attrs=a.attrs||kb(af);this.params=a.params||kb(bf);this.minVersion=a.min_version||"8.0.0";this.fallback=a.fallback||null;this.fallbackMessage=a.fallbackMessage||null;this.html5=!!a.html5;this.disable=a.disable||{};this.loaded=!!a.loaded;this.messages=a.messages||{}}
var $e={enablejsapi:1},af={},bf={allowscriptaccess:"always",allowfullscreen:"true",bgcolor:"#000000"};function cf(a){a instanceof Ze||(a=new Ze(a));return a}
Ze.prototype.clone=function(){var a=new Ze,b;for(b in this)if(this.hasOwnProperty(b)){var c=this[b];"object"==ca(c)?a[b]=kb(c):a[b]=c}return a};function df(a,b,c,d){this.top=a;this.right=b;this.bottom=c;this.left=d}
g=df.prototype;g.getHeight=function(){return this.bottom-this.top};
g.clone=function(){return new df(this.top,this.right,this.bottom,this.left)};
g.contains=function(a){return this&&a?a instanceof df?a.left>=this.left&&a.right<=this.right&&a.top>=this.top&&a.bottom<=this.bottom:a.x>=this.left&&a.x<=this.right&&a.y>=this.top&&a.y<=this.bottom:!1};
g.ceil=function(){this.top=Math.ceil(this.top);this.right=Math.ceil(this.right);this.bottom=Math.ceil(this.bottom);this.left=Math.ceil(this.left);return this};
g.floor=function(){this.top=Math.floor(this.top);this.right=Math.floor(this.right);this.bottom=Math.floor(this.bottom);this.left=Math.floor(this.left);return this};
g.round=function(){this.top=Math.round(this.top);this.right=Math.round(this.right);this.bottom=Math.round(this.bottom);this.left=Math.round(this.left);return this};function ef(a,b,c,d){this.left=a;this.top=b;this.width=c;this.height=d}
g=ef.prototype;g.clone=function(){return new ef(this.left,this.top,this.width,this.height)};
g.contains=function(a){return a instanceof ef?this.left<=a.left&&this.left+this.width>=a.left+a.width&&this.top<=a.top&&this.top+this.height>=a.top+a.height:a.x>=this.left&&a.x<=this.left+this.width&&a.y>=this.top&&a.y<=this.top+this.height};
g.ceil=function(){this.left=Math.ceil(this.left);this.top=Math.ceil(this.top);this.width=Math.ceil(this.width);this.height=Math.ceil(this.height);return this};
g.floor=function(){this.left=Math.floor(this.left);this.top=Math.floor(this.top);this.width=Math.floor(this.width);this.height=Math.floor(this.height);return this};
g.round=function(){this.left=Math.round(this.left);this.top=Math.round(this.top);this.width=Math.round(this.width);this.height=Math.round(this.height);return this};function ff(a){ff[" "](a);return a}
ff[" "]=t;function gf(a,b){var c=ne(a);return c.defaultView&&c.defaultView.getComputedStyle&&(c=c.defaultView.getComputedStyle(a,null))?c[b]||c.getPropertyValue(b)||"":""}
function hf(a,b){return gf(a,b)||(a.currentStyle?a.currentStyle[b]:null)||a.style&&a.style[b]}
function jf(a){var b;try{b=a.getBoundingClientRect()}catch(c){return{left:0,top:0,right:0,bottom:0}}L&&a.ownerDocument.body&&(a=a.ownerDocument,b.left-=a.documentElement.clientLeft+a.body.clientLeft,b.top-=a.documentElement.clientTop+a.body.clientTop);return b}
function kf(a,b){"number"==typeof a&&(a=(b?Math.round(a):a)+"px");return a}
function lf(a){var b=mf;if("none"!=hf(a,"display"))return b(a);var c=a.style,d=c.display,e=c.visibility,f=c.position;c.visibility="hidden";c.position="absolute";c.display="inline";a=b(a);c.display=d;c.position=f;c.visibility=e;return a}
function mf(a){var b=a.offsetWidth,c=a.offsetHeight,d=cd&&!b&&!c;return p(b)&&!d||!a.getBoundingClientRect?new ie(b,c):(a=jf(a),new ie(a.right-a.left,a.bottom-a.top))}
function nf(a,b){if(/^\d+px?$/.test(b))return parseInt(b,10);var c=a.style.left,d=a.runtimeStyle.left;a.runtimeStyle.left=a.currentStyle.left;a.style.left=b;var e=a.style.pixelLeft;a.style.left=c;a.runtimeStyle.left=d;return e}
function of(a,b){var c=a.currentStyle?a.currentStyle[b]:null;return c?nf(a,c):0}
var pf={thin:2,medium:4,thick:6};function qf(a,b){if("none"==(a.currentStyle?a.currentStyle[b+"Style"]:null))return 0;var c=a.currentStyle?a.currentStyle[b+"Width"]:null;return c in pf?pf[c]:nf(a,c)}
;var rf=B("Firefox"),sf=Zc()||B("iPod"),tf=B("iPad"),uf=B("Android")&&!(rb()||B("Firefox")||B("Opera")||B("Silk")),vf=rb(),wf=B("Safari")&&!(rb()||B("Coast")||B("Opera")||B("Edge")||B("Silk")||B("Android"))&&!(Zc()||B("iPad")||B("iPod"));function xf(){var a;if(a=We.get("PREF",void 0)){a=unescape(a).split("&");for(var b=0;b<a.length;b++){var c=a[b].split("="),d=c[0];(c=c[1])&&(yf[d]=c.toString())}}}
ba(xf);var yf=r("yt.prefs.UserPrefs.prefs_")||{};q("yt.prefs.UserPrefs.prefs_",yf,void 0);function zf(a){if(/^f([1-9][0-9]*)$/.test(a))throw"ExpectedRegexMatch: "+a;}
function Af(a){if(!/^\w+$/.test(a))throw"ExpectedRegexMismatch: "+a;}
function Bf(a){a=void 0!==yf[a]?yf[a].toString():null;return null!=a&&/^[A-Fa-f0-9]+$/.test(a)?parseInt(a,16):null}
xf.prototype.get=function(a,b){Af(a);zf(a);var c=void 0!==yf[a]?yf[a].toString():null;return null!=c?c:b?b:""};
xf.prototype.set=function(a,b){Af(a);zf(a);if(null==b)throw"ExpectedNotNull";yf[a]=b.toString()};
function Cf(a,b){return!!((Bf("f"+(Math.floor(b/31)+1))||0)&1<<b%31)}
xf.prototype.remove=function(a){Af(a);zf(a);delete yf[a]};
xf.prototype.clear=function(){yf={}};function Df(a,b){(a=oe(a))&&a.style&&(a.style.display=b?"":"none",ge(a,"hid",!b))}
function Ef(a){A(arguments,function(a){!ea(a)||a instanceof Element?Df(a,!0):A(a,function(a){Ef(a)})})}
function Ff(a){A(arguments,function(a){!ea(a)||a instanceof Element?Df(a,!1):A(a,function(a){Ff(a)})})}
;function Gf(){this.g=this.f=this.b=0;this.h="";var a=r("window.navigator.plugins"),b=r("window.navigator.mimeTypes"),a=a&&a["Shockwave Flash"],b=b&&b["application/x-shockwave-flash"],b=a&&b&&b.enabledPlugin&&a.description||"";if(a=b){var c=a.indexOf("Shockwave Flash");0<=c&&(a=a.substr(c+15));for(var c=a.split(" "),d="",a="",e=0,f=c.length;e<f;e++)if(d)if(a)break;else a=c[e];else d=c[e];d=d.split(".");c=parseInt(d[0],10)||0;d=parseInt(d[1],10)||0;e=0;if("r"==a.charAt(0)||"d"==a.charAt(0))e=parseInt(a.substr(1),
10)||0;a=[c,d,e]}else a=[0,0,0];this.h=b;b=a;this.b=b[0];this.f=b[1];this.g=b[2];if(0>=this.b){var h,k,l,n;if(hc)try{h=new ActiveXObject("ShockwaveFlash.ShockwaveFlash")}catch(D){h=null}else l=document.body,n=document.createElement("object"),n.setAttribute("type","application/x-shockwave-flash"),h=l.appendChild(n);if(h&&"GetVariable"in h)try{k=h.GetVariable("$version")}catch(D){k=""}l&&n&&l.removeChild(n);(h=k||"")?(h=h.split(" ")[1].split(","),h=[parseInt(h[0],10)||0,parseInt(h[1],10)||0,parseInt(h[2],
10)||0]):h=[0,0,0];this.b=h[0];this.f=h[1];this.g=h[2]}}
ba(Gf);function Hf(a,b,c,d){b="string"==typeof b?b.split("."):[b,c,d];b[0]=parseInt(b[0],10)||0;b[1]=parseInt(b[1],10)||0;b[2]=parseInt(b[2],10)||0;return a.b>b[0]||a.b==b[0]&&a.f>b[1]||a.b==b[0]&&a.f==b[1]&&a.g>=b[2]}
function If(a){return-1<a.h.indexOf("Gnash")&&-1==a.h.indexOf("AVM2")||9==a.b&&1==a.f||9==a.b&&0==a.f&&1==a.g?!1:9<=a.b}
function Jf(a){return ed?!Hf(a,11,2):dd?!Hf(a,11,3):!If(a)}
;function Kf(a,b,c){if(b){a=u(a)?pe(a):a;var d=kb(c.attrs);d.tabindex=0;var e=kb(c.params);e.flashvars=Fd(c.args);if(hc){d.classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000";e.movie=b;b=document.createElement("object");for(var f in d)b.setAttribute(f,d[f]);for(f in e)d=document.createElement("param"),d.setAttribute("name",f),d.setAttribute("value",e[f]),b.appendChild(d)}else{d.type="application/x-shockwave-flash";d.src=b;b=document.createElement("embed");b.setAttribute("name",d.id);for(f in d)b.setAttribute(f,
d[f]);for(f in e)b.setAttribute(f,e[f])}e=document.createElement("div");e.appendChild(b);a.innerHTML=e.innerHTML}}
function Lf(a,b,c){if(a&&a.attrs&&a.attrs.id){a=cf(a);var d=!!b,e=oe(a.attrs.id),f=e?e.parentNode:null;if(e&&f){if(window!=window.top){var h=null;if(document.referrer){var k=document.referrer.substring(0,128);Kd(k)||(h=k)}else h="unknown";h&&(d=!0,a.args.framer=h)}h=Gf.getInstance();if(Hf(h,a.minVersion)){var k=Mf(a,h),l="";-1<navigator.userAgent.indexOf("Sony/COM2")||(l=e.getAttribute("src")||e.movie);(l!=k||d)&&Kf(f,k,a);Jf(h)&&Nf()}else Of(f,a,h);c&&c()}else J(function(){Lf(a,b,c)},50)}}
function Of(a,b,c){0==c.b&&b.fallback?b.fallback():0==c.b&&b.fallbackMessage?b.fallbackMessage():a.innerHTML='<div id="flash-upgrade">'+fc()+"</div>"}
function Mf(a,b){return If(b)&&a.url||(-1<navigator.userAgent.indexOf("Sony/COM2")&&!Hf(b,9,1,58)?!1:!0)&&a.urlV9As2||a.url}
function Nf(){var a=oe("flash10-promo-div"),b=Cf(xf.getInstance(),107);a&&!b&&Ef(a)}
;function Pf(a){if(window.spf){var b=a.match(Qf);spf.style.load(a,b?b[1]:"",void 0)}else Rf(a)}
function Rf(a){var b=Sf(a),c=document.getElementById(b),d=c&&C(c,"loaded");d||c&&!d||(c=Tf(a,b,function(){C(c,"loaded")||(Fb(c,"loaded","true"),qc(b),J(oa(tc,b),0))}))}
function Tf(a,b,c){var d=document.createElement("link");d.id=b;d.rel="stylesheet";d.onload=function(){c&&setTimeout(c,0)};
Eb(d,a);(document.getElementsByTagName("head")[0]||document.body).appendChild(d);return d}
function Sf(a){var b=document.createElement("a");Eb(b,a);a=b.href.replace(/^[a-zA-Z]+:\/\//,"//");return"css-"+Ha(a)}
var Qf=/cssbin\/(?:debug-)?([a-zA-Z0-9_-]+?)(?:-2x|-web|-rtl|-vfl|.css)/;var Uf;var Vf=ob,Vf=Vf.toLowerCase();if(-1!=Vf.indexOf("android")){var Wf=Vf.match(/android\D*(\d\.\d)[^\;|\)]*[\;\)]/);if(Wf)Uf=Number(Wf[1]);else{var Xf={cupcake:1.5,donut:1.6,eclair:2,froyo:2.2,gingerbread:2.3,honeycomb:3,"ice cream sandwich":4,jellybean:4.1},Yf=Vf.match("("+eb(Xf).join("|")+")");Uf=Yf?Xf[Yf[0]]:0}}else Uf=void 0;var Zf=sf||tf;var $f=['video/mp4; codecs="avc1.42001E, mp4a.40.2"','video/webm; codecs="vp8.0, vorbis"'],ag=['audio/mp4; codecs="mp4a.40.2"'];function bg(a){E.call(this);this.b=[];this.f=a||this}
y(bg,E);function cg(a,b,c,d){d=dc(w(d,a.f));b.addEventListener(c,d);a.b.push({target:b,name:c,Cb:d})}
bg.prototype.sb=function(a){for(var b=0;b<this.b.length;b++)if(this.b[b]==a){this.b.splice(b,1);a.target.removeEventListener(a.name,a.Cb);break}};
function dg(a){for(;a.b.length;){var b=a.b.pop();b.target.removeEventListener(b.name,b.Cb)}}
bg.prototype.w=function(){dg(this);bg.A.w.call(this)};function eg(a){return I("EXPERIMENT_FLAGS",{})[a]}
;function fg(){this.b={apiaryHost:I("APIARY_HOST",void 0),Qe:I("APIARY_HOST_FIRSTPARTY",void 0),gapiHintOverride:I("GAPI_HINT_OVERRIDE"),gapiHintParams:I("GAPI_HINT_PARAMS",void 0),innertubeApiKey:I("INNERTUBE_API_KEY",void 0),innertubeApiVersion:I("INNERTUBE_API_VERSION",void 0),rd:I("INNERTUBE_CONTEXT_CLIENT_NAME","WEB"),innertubeContextClientVersion:I("INNERTUBE_CONTEXT_CLIENT_VERSION",void 0),td:I("INNERTUBE_CONTEXT_HL",void 0),sd:I("INNERTUBE_CONTEXT_GL",void 0),te:I("XHR_APIARY_HOST",void 0)}}
;var gg={log_event:"events",log_interaction:"interactions"},hg={},ig={},jg=0,kg=r("yt.logging.transport.logsQueue_")||{};q("yt.logging.transport.logsQueue_",kg,void 0);
function lg(){K(jg);if(!ib(kg)){for(var a in kg){var b=hg[a];if(!b){var c=ig[a];if(!c)continue;b=new c;hg[a]=b}c=b.b;c={client:{hl:c.td,gl:c.sd,clientName:c.rd,clientVersion:c.innertubeContextClientVersion}};I("DELEGATED_SESSION_ID")&&(c.user={onBehalfOfUser:I("DELEGATED_SESSION_ID")});c={context:c};c.requestTimeMs=Math.round(gc());c[gg[a]]=kg[a];var d=b,b={},d="//"+d.b.te+("/youtubei/"+d.b.innertubeApiVersion+"/"+a)+"?alt=json&key="+d.b.innertubeApiKey,c={headers:{"Content-Type":"application/json",
"X-Goog-Visitor-Id":I("VISITOR_DATA")},J:c,Bc:"JSON",Ea:b.Ea,Z:b.Z,onError:b.onError,timeout:b.timeout,method:"POST"};c.J||(c.J={});Rd(d,c);delete kg[a]}ib(kg)||mg()}}
function mg(){K(jg);jg=J(lg,I("VISIBILITY_TIMEOUT",1E4))}
;function ng(a,b){var c={};c.eventTimeMs=Math.round(gc());c[a]=b;kg.log_event=kg.log_event||[];var d=kg.log_event;d.push(c);ig.log_event=fg;20<=d.length?lg():mg()}
;function og(a,b){this.f=this.o=this.h="";this.j=null;this.i=this.b="";this.l=!1;var c;a instanceof og?(this.l=p(b)?b:a.l,pg(this,a.h),this.o=a.o,qg(this,a.f),rg(this,a.j),this.b=a.b,sg(this,a.g.clone()),this.i=a.i):a&&(c=String(a).match(yd))?(this.l=!!b,pg(this,c[1]||"",!0),this.o=tg(c[2]||""),qg(this,c[3]||"",!0),rg(this,c[4]),this.b=tg(c[5]||"",!0),sg(this,c[6]||"",!0),this.i=tg(c[7]||"")):(this.l=!!b,this.g=new ug(null,0,this.l))}
og.prototype.toString=function(){var a=[],b=this.h;b&&a.push(vg(b,wg,!0),":");var c=this.f;if(c||"file"==b)a.push("//"),(b=this.o)&&a.push(vg(b,wg,!0),"@"),a.push(encodeURIComponent(String(c)).replace(/%25([0-9a-fA-F]{2})/g,"%$1")),c=this.j,null!=c&&a.push(":",String(c));if(c=this.b)this.f&&"/"!=c.charAt(0)&&a.push("/"),a.push(vg(c,"/"==c.charAt(0)?xg:yg,!0));(c=this.g.toString())&&a.push("?",c);(c=this.i)&&a.push("#",vg(c,zg));return a.join("")};
og.prototype.resolve=function(a){var b=this.clone(),c=!!a.h;c?pg(b,a.h):c=!!a.o;c?b.o=a.o:c=!!a.f;c?qg(b,a.f):c=null!=a.j;var d=a.b;if(c)rg(b,a.j);else if(c=!!a.b){if("/"!=d.charAt(0))if(this.f&&!this.b)d="/"+d;else{var e=b.b.lastIndexOf("/");-1!=e&&(d=b.b.substr(0,e+1)+d)}e=d;if(".."==e||"."==e)d="";else if(-1!=e.indexOf("./")||-1!=e.indexOf("/.")){for(var d=0==e.lastIndexOf("/",0),e=e.split("/"),f=[],h=0;h<e.length;){var k=e[h++];"."==k?d&&h==e.length&&f.push(""):".."==k?((1<f.length||1==f.length&&
""!=f[0])&&f.pop(),d&&h==e.length&&f.push("")):(f.push(k),d=!0)}d=f.join("/")}else d=e}c?b.b=d:c=""!==a.g.toString();c?sg(b,tg(a.g.toString())):c=!!a.i;c&&(b.i=a.i);return b};
og.prototype.clone=function(){return new og(this)};
function pg(a,b,c){a.h=c?tg(b,!0):b;a.h&&(a.h=a.h.replace(/:$/,""))}
function qg(a,b,c){a.f=c?tg(b,!0):b}
function rg(a,b){if(b){b=Number(b);if(isNaN(b)||0>b)throw Error("Bad port number "+b);a.j=b}else a.j=null}
function sg(a,b,c){b instanceof ug?(a.g=b,Ag(a.g,a.l)):(c||(b=vg(b,Bg)),a.g=new ug(b,0,a.l))}
function O(a,b,c){a.g.set(b,c)}
function Cg(a,b,c){da(c)||(c=[String(c)]);Dg(a.g,b,c)}
function Eg(a){O(a,"zx",Math.floor(2147483648*Math.random()).toString(36)+Math.abs(Math.floor(2147483648*Math.random())^x()).toString(36));return a}
function Fg(a){return a instanceof og?a.clone():new og(a,void 0)}
function Gg(a,b,c,d){var e=new og(null,void 0);a&&pg(e,a);b&&qg(e,b);c&&rg(e,c);d&&(e.b=d);return e}
function tg(a,b){return a?b?decodeURI(a.replace(/%25/g,"%2525")):decodeURIComponent(a):""}
function vg(a,b,c){return u(a)?(a=encodeURI(a).replace(b,Hg),c&&(a=a.replace(/%25([0-9a-fA-F]{2})/g,"%$1")),a):null}
function Hg(a){a=a.charCodeAt(0);return"%"+(a>>4&15).toString(16)+(a&15).toString(16)}
var wg=/[#\/\?@]/g,yg=/[\#\?:]/g,xg=/[\#\?]/g,Bg=/[\#\?@]/g,zg=/#/g;function ug(a,b,c){this.f=this.b=null;this.g=a||null;this.h=!!c}
function Ig(a){a.b||(a.b=new Mc,a.f=0,a.g&&Ad(a.g,function(b,c){Jg(a,sa(b),c)}))}
g=ug.prototype;g.N=function(){Ig(this);return this.f};
function Jg(a,b,c){Ig(a);a.g=null;b=Kg(a,b);var d=a.b.get(b);d||a.b.set(b,d=[]);d.push(c);a.f=a.f+1}
g.remove=function(a){Ig(this);a=Kg(this,a);return Oc(this.b.f,a)?(this.g=null,this.f=this.f-this.b.get(a).length,this.b.remove(a)):!1};
g.clear=function(){this.b=this.g=null;this.f=0};
g.isEmpty=function(){Ig(this);return 0==this.f};
function Lg(a,b){Ig(a);b=Kg(a,b);return Oc(a.b.f,b)}
g.Sa=function(a){var b=this.O();return Pa(b,a)};
g.ia=function(){Ig(this);for(var a=this.b.O(),b=this.b.ia(),c=[],d=0;d<b.length;d++)for(var e=a[d],f=0;f<e.length;f++)c.push(b[d]);return c};
g.O=function(a){Ig(this);var b=[];if(u(a))Lg(this,a)&&(b=Ta(b,this.b.get(Kg(this,a))));else{a=this.b.O();for(var c=0;c<a.length;c++)b=Ta(b,a[c])}return b};
g.set=function(a,b){Ig(this);this.g=null;a=Kg(this,a);Lg(this,a)&&(this.f=this.f-this.b.get(a).length);this.b.set(a,[b]);this.f=this.f+1;return this};
g.get=function(a,b){var c=a?this.O(a):[];return 0<c.length?String(c[0]):b};
function Dg(a,b,c){a.remove(b);0<c.length&&(a.g=null,a.b.set(Kg(a,b),Ua(c)),a.f=a.f+c.length)}
g.toString=function(){if(this.g)return this.g;if(!this.b)return"";for(var a=[],b=this.b.ia(),c=0;c<b.length;c++)for(var d=b[c],e=encodeURIComponent(String(d)),d=this.O(d),f=0;f<d.length;f++){var h=e;""!==d[f]&&(h+="="+encodeURIComponent(String(d[f])));a.push(h)}return this.g=a.join("&")};
g.clone=function(){var a=new ug;a.g=this.g;this.b&&(a.b=this.b.clone(),a.f=this.f);return a};
function Kg(a,b){var c=String(b);a.h&&(c=c.toLowerCase());return c}
function Ag(a,b){b&&!a.h&&(Ig(a),a.g=null,a.b.forEach(function(a,b){var e=b.toLowerCase();b!=e&&(this.remove(b),Dg(this,e,a))},a));
a.h=b}
g.extend=function(a){for(var b=0;b<arguments.length;b++)Tc(arguments[b],function(a,b){Jg(this,b,a)},this)};var Mg="corp.google.com googleplex.com youtube.com youtube-nocookie.com youtubeeducation.com borg.google.com prod.google.com sandbox.google.com books.googleusercontent.com docs.google.com drive.google.com mail.google.com photos.google.com plus.google.com lh2.google.com picasaweb.google.com play.google.com googlevideo.com talkgadget.google.com survey.g.doubleclick.net youtube.googleapis.com vevo.com".split(" "),Ng="";
function Og(a){return a&&a==Ng?!0:(new RegExp("^(https?:)?//([a-z0-9-]{1,63}\\.)*("+Mg.join("|").replace(/\./g,".")+")(:[0-9]+)?([/?#]|$)","i")).test(a)?(Ng=a,!0):!1}
;var Pg={},Qg=0,Rg=r("yt.net.ping.workerUrl_")||null;q("yt.net.ping.workerUrl_",Rg,void 0);function Sg(a){try{window.navigator&&window.navigator.sendBeacon&&window.navigator.sendBeacon(a,"")||a&&Tg(a)}catch(b){a&&Tg(a)}}
function Tg(a){var b=new Image,c=""+Qg++;Pg[c]=b;b.onload=b.onerror=function(){delete Pg[c]};
b.src=a}
;function P(a,b){this.version=a;this.args=b}
function Ug(a){if(!a.wa){var b={};a.call(b);a.wa=b.version}return a.wa}
function Vg(a,b){function c(){a.apply(this,b.args)}
if(!b.args||!b.version)throw Error("yt.pubsub2.Data.deserialize(): serializedData is incomplete.");var d;try{d=Ug(a)}catch(e){}if(!d||b.version!=d)throw Error("yt.pubsub2.Data.deserialize(): serializedData version is incompatible.");c.prototype=a.prototype;try{return new c}catch(e){throw e.message="yt.pubsub2.Data.deserialize(): "+e.message,e;}}
function Q(a,b){this.topic=a;this.b=b}
Q.prototype.toString=function(){return this.topic};var Wg=r("yt.pubsub2.instance_")||new H;H.prototype.subscribe=H.prototype.subscribe;H.prototype.unsubscribeByKey=H.prototype.ha;H.prototype.publish=H.prototype.u;H.prototype.clear=H.prototype.clear;q("yt.pubsub2.instance_",Wg,void 0);var Xg=r("yt.pubsub2.subscribedKeys_")||{};q("yt.pubsub2.subscribedKeys_",Xg,void 0);var Yg=r("yt.pubsub2.topicToKeys_")||{};q("yt.pubsub2.topicToKeys_",Yg,void 0);var Zg=r("yt.pubsub2.isAsync_")||{};q("yt.pubsub2.isAsync_",Zg,void 0);
q("yt.pubsub2.skipSubKey_",null,void 0);function R(a,b){var c=$g();c&&c.publish.call(c,a.toString(),a,b)}
function ah(a,b,c){var d=$g();if(!d)return 0;var e=d.subscribe(a.toString(),function(d,h){if(!window.yt.pubsub2.skipSubKey_||window.yt.pubsub2.skipSubKey_!=e){var k=function(){if(Xg[e])try{if(h&&a instanceof Q&&a!=d)try{h=Vg(a.b,h)}catch(k){throw k.message="yt.pubsub2 cross-binary conversion error for "+a.toString()+": "+k.message,k;}b.call(c||window,h)}catch(k){ec(k)}};
Zg[a.toString()]?r("yt.scheduler.instance")?Yd(k,void 0):J(k,0):k()}});
Xg[e]=!0;Yg[a.toString()]||(Yg[a.toString()]=[]);Yg[a.toString()].push(e);return e}
function bh(a){var b=$g();b&&(fa(a)&&(a=[a]),A(a,function(a){b.unsubscribeByKey(a);delete Xg[a]}))}
function $g(){return r("yt.pubsub2.instance_")}
;var ch=x().toString();function dh(a){P.call(this,1,arguments)}
y(dh,P);var eh=new Q("timing-sent",dh);function fh(a){var b=a||window;if(!(b.performance&&b.performance.timing&&b.performance.getEntriesByType))return{qb:0,Jc:0};a=se(b||window);for(var c=[],d=b.document.getElementsByTagName("*"),e=0,f=d.length;e<f;e++){var h=d[e];if("IMG"==h.tagName||"IFRAME"==h.tagName){var k=gh(h,h.src,a);if(k){if("IFRAME"==h.tagName){var l;try{l=fh(h.contentWindow).qb}catch(n){l=0}0<l&&(k.timing=l)}c.push(k)}}(k=b.getComputedStyle(h)["background-image"])&&(k=hh.exec(k))&&1<k.length&&(k=gh(h,k[1],a))&&c.push(k)}l=b.performance.getEntriesByType("resource");
h=b.performance.getEntriesByType("mark");d={};e=0;for(f=l.length;e<f;e++)k=l[e],d[k.name]=k.responseEnd;e=0;for(f=h.length;e<f;e++)k=h[e],"mark_iframe_loaded: "==k.name.slice(0,20)&&(d[k.name.slice(20)]=k.startTime);e=0;for(f=c.length;e<f;e++)h=c[e],h.timing||(h.timing=d[h.url]||0);b=ih(b,l);a=jh(b,a,c);h=c=0;if(a.length)for(d=l=0,e=a.length;d<e;d++)f=a[d],h=f.timing-h,0<h&&1>l&&(c+=(1-l)*h),h=f.timing,l=f.progress;return{qb:Math.round(c||b),Jc:h}}
function gh(a,b,c){if(b&&a.getBoundingClientRect){var d=a.getBoundingClientRect();a=Math.max(d.top,0);var e=Math.min(d.right,c.width);c=Math.min(d.bottom,c.height);d=Math.max(d.left,0);if(c>a&&e>d)return new kh(a,e,c,d,b)}return null}
function ih(a,b){var c,d=a.performance.timing.navigationStart;if("msFirstPaint"in a.performance.timing)c=a.performance.timing.b-d;else if("chrome"in a&&"loadTimes"in a.chrome){var e=a.chrome.loadTimes(),f=e.firstPaintTime;if(0<f){var h=e.startLoadTime;"requestTime"in e&&(h=e.requestTime);f>=h&&(c=1E3*(f-h))}}if(void 0===c||0>c||12E4<c){c=a.performance.timing.responseStart-d;for(var k={},d=a.document.getElementsByTagName("head")[0].children,e=0,f=d.length;e<f;e++)h=d[e],"SCRIPT"==h.tagName&&h.src&&
!h.async?k[h.src]=!0:"LINK"==h.tagName&&"stylesheet"==h.rel&&h.href&&(k[h.href]=!0);b.some(function(a){if(!k[a.name]||"script"!=a.initiatorType&&"link"!=a.initiatorType)return!0;a=a.responseEnd;if(void 0===c||a>c)c=a})}return Math.max(c,0)||0}
function jh(a,b,c){for(var d={0:0},e=0,f=0,h=c.length;f<h;f++){var k=c[f],l=a;k.timing>a&&(l=k.timing);d[l]||(d[l]=0);k=(k.b-k.h)*(k.g-k.f);d[l]+=k;e+=k}f=b.width*b.height;0<f&&(f=.1*Math.max(f-e,0),a in d||(d[a]=0),d[a]+=f,e+=f);a=[];if(e){for(var n in d)b=new lh(parseFloat(n),d[n]),a.push(b);a.sort(function(a,b){return a.timing-b.timing});
f=d=0;for(h=a.length;f<h;f++)b=a[f],d+=b.Bb,b.progress=d/e}return a}
function kh(a,b,c,d,e){this.b=c;this.f=d;this.g=b;this.h=a;this.url=e}
function lh(a,b){this.Bb=b;this.timing=a}
var hh=/url\(["']?(http[^'"\)]+)['"]?\)/i;var mh={'script[name="scheduler/scheduler"]':"sj",'script[name="player/base"]':"pj",'link[rel="stylesheet"][name="www-player"]':"pc",'script[name="desktop_polymer/desktop_polymer"]':"dpj",'link[rel="import"][name="desktop_polymer"]':"dph",'script[name="mobile_polymer/mobile_polymer"]':"mpj",'link[rel="import"][name="mobile_polymer"]':"mph",'script[name="mobile-polymer-player/mobile-polymer-player"]':"mppj",'link[rel="stylesheet"][name="mobile-polymer-player"]':"mppc"},S=window.performance||window.mozPerformance||
window.msPerformance||window.webkitPerformance||{},nh=w(S.clearResourceTimings||S.webkitClearResourceTimings||S.mozClearResourceTimings||S.msClearResourceTimings||S.oClearResourceTimings||t,S),oh=S.mark?function(a){S.mark(a)}:t;
function ph(a){oh(a);qh()[a]=gc();if(eg("csi_on_gel")){var b;b=rh().nonce;if(!b){var c;a:{if(window.crypto&&window.crypto.getRandomValues)try{var d=Array(16),e=new Uint8Array(16);window.crypto.getRandomValues(e);for(b=0;b<d.length;b++)d[b]=e[b];c=d;break a}catch(zq){}b=Array(16);for(var f=0;16>f;f++){var h=x();for(c=0;c<h%23;c++)b[f]=Math.random();b[f]=Math.floor(256*Math.random())}if(ch)for(f=1,h=0;h<ch.length;h++)b[f%16]=b[f%16]^b[(f-1)%16]/4^ch.charCodeAt(h),f++;c=b}b=[];for(f=0;f<c.length;f++)b.push("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_".charAt(c[f]&
63));b=b.join("");rh().nonce=b}"_start"==a?ng("latencyActionBaselined",{clientActionNonce:b}):ng("latencyActionTicked",{tickName:a,clientActionNonce:b})}else if(c=I("TIMING_ACTION",void 0),a=qh(),r("yt.timing.ready_")&&c&&a._start&&sh()){c=!0;d=I("TIMING_WAIT",[]);if(d.length)for(var e=0,k=d.length;e<k;++e)if(!(d[e]in a)){c=!1;break}if(c)if(d=qh(),a=rh().span,e=rh().info,c=r("yt.timing.reportbuilder_")){if(c=c(d,a,e,void 0))th(c),uh()}else{var l=I("TIMING_ACTION",void 0),k=I("CSI_SERVICE_NAME","youtube");
c={v:2,s:k,action:l};if(S.now&&S.timing){var n=S.timing.navigationStart+S.now(),n=Math.round(x()-n);e.yt_hrd=n}var n=I("TIMING_INFO",{}),D;for(D in n)e[D]=n[D];D=e.srt;delete e.srt;var v;void 0===d.srt&&(D||0===D||(v=S.timing||{},D=Math.max(0,v.responseStart-v.navigationStart),isNaN(D)&&e.pt&&(D=e.pt)),D||0===D)&&(e.srt=Math.round(D));e.h5jse&&(n=window.location.protocol+r("ytplayer.config.assets.js"),(n=S.getEntriesByName?S.getEntriesByName(n)[0]:null)?e.h5jse=Math.round(e.h5jse-n.responseEnd):delete e.h5jse);
d.aft=sh();n=d._start;if("cold"==e.yt_lt){v||(v=S.timing||{});var z;a:if(z=v,z.msFirstPaint)z=Math.max(0,z.msFirstPaint);else{var F=window.chrome;if(F&&(F=F.loadTimes,ga(F))){var F=F(),le=1E3*Math.min(F.requestTime||Infinity,F.startLoadTime||Infinity),le=Infinity===le?0:z.navigationStart-le;z=Math.max(0,Math.round(1E3*F.firstPaintTime+le)||0);break a}z=0}0<z&&z>n&&(d.fpt=z);z=a||rh().span;F=v.redirectEnd-v.redirectStart;0<F&&(z.rtime_=F);F=v.domainLookupEnd-v.domainLookupStart;0<F&&(z.dns_=F);F=v.connectEnd-
v.connectStart;0<F&&(z.tcp_=F);F=v.connectEnd-v.secureConnectionStart;v.secureConnectionStart>=v.navigationStart&&0<F&&(z.stcp_=F);F=v.responseStart-v.requestStart;0<F&&(z.req_=F);F=v.responseEnd-v.responseStart;0<F&&(z.rcv_=F);S.getEntriesByType&&vh(d);(v=I("SPEEDINDEX_FOR_ACTIONS",void 0))&&-1<v.indexOf(l)&&(v=gc(),l=fh(),z=gc(),0<l.qb&&(e.si=l.qb,d.vsc=wh(l.Jc),d.sics=v,d.sice=z));v=[];if(document.querySelector&&S&&S.getEntriesByName)for(var ja in mh)if(l=document.querySelector(ja))z="",F=l.nodeName,
"SCRIPT"==F?z=l.src:"LINK"==F&&(z=l.href),z&&(l=S.getEntriesByName(z))&&l[0]&&v.push(mh[ja]+"."+Math.round(l[0].duration));v.length&&(e.rs=v.join(","))}l=qh();ja=l.pbr;v=l.vc;l=l.pbs;ja&&v&&l&&ja<v&&v<l&&1==rh().info.yt_vis&&"youtube"==k&&(rh().info.yt_lt="hot_bg",ja=d.vc,k=d.pbs,delete d.aft,e.aft=Math.round(k-ja));(ja=I("PREVIOUS_ACTION"))&&(e.pa=ja);e.p=I("CLIENT_PROTOCOL")||"unknown";e.t=I("CLIENT_TRANSPORT")||"unknown";window.navigator&&window.navigator.sendBeacon&&(e.ba=1);for(h in e)"_"!=h.charAt(0)&&
(c[h]=e[h]);d.ps=gc();h={};ja=[];for(f in d)"_"!=f.charAt(0)&&(z=Math.round(d[f]-n),eg("enable_negative_ticks")||(z=Math.max(z,0)),h[f]=z,ja.push(f+"."+z));c.rt=ja.join(",");f=c;ja=[];for(b in a)"_"!=b.charAt(0)&&ja.push(b+"."+Math.round(a[b]));f.it=ja.join(",");(b=r("ytdebug.logTiming"))&&b(c,h,a);uh();I("EXP_DEFER_CSI_PING")?(xh(),q("yt.timing.deferredPingArgs_",c,void 0),b=J(xh,0),q("yt.timing.deferredPingTimer_",b,void 0)):th(c);R(eh,new dh(h.aft+(D||0)))}}}
function uh(){yh();nh();q("yt.timing.pingSent_",!1,void 0)}
function sh(){var a=qh();if(a.aft)return a.aft;for(var b=I("TIMING_AFT_KEYS",["ol"]),c=b.length,d=0;d<c;d++){var e=a[b[d]];if(e)return e}return NaN}
function wh(a){return Math.round(S.timing.navigationStart+a)}
function vh(a){var b=window.location.protocol,c=S.getEntriesByType("resource"),d=c.filter(function(a){return 0==a.name.indexOf(b+"//fonts.googleapis.com/css?family=")})[0],c=c.filter(function(a){return 0==a.name.indexOf(b+"//fonts.gstatic.com/s/")}).reduce(function(a,b){return b.duration>a.duration?b:a},{duration:0});
d&&0<d.startTime&&0<d.responseEnd&&(a.wfcs=wh(d.startTime),a.wfce=wh(d.responseEnd));c&&0<c.startTime&&0<c.responseEnd&&(a.wffs=wh(c.startTime),a.wffe=wh(c.responseEnd))}
function th(a){if(I("DEBUG_CSI_DATA")){var b=r("yt.timing.csiData");b||(b=[],q("yt.timing.csiData",b,void 0));b.push({page:location.href,time:new Date,args:a})}I("EXP_DEFER_CSI_PING")&&(K(r("yt.timing.deferredPingTimer_")),q("yt.timing.deferredPingArgs_",null,void 0));var c="https:"==window.location.protocol?"https://gg.google.com/csi":"http://csi.gstatic.com/csi",c=I("CSI_LOG_WITH_YT")?"/csi_204":c,b="",d;for(d in a)b+="&"+d+"="+a[d];a=c+"?"+b.substring(1);b=I("DOUBLE_LOG_CSI")?"/csi_204?"+b.substring(1):
null;window.navigator&&window.navigator.sendBeacon?(Sg(a),b&&Sg(b)):(a&&Tg(a),b&&b&&Tg(b));q("yt.timing.pingSent_",!0,void 0)}
function xh(a){if(I("EXP_DEFER_CSI_PING")){var b=r("yt.timing.deferredPingArgs_");b&&(a&&(b.yt_fss=a),th(b))}}
function qh(){return rh().tick}
function rh(){return r("ytcsi.data_")||yh()}
function yh(){var a={tick:{},span:{},info:{}};q("ytcsi.data_",a,void 0);return a}
;var zh={"api.invalidparam":2,auth:150,"drm.auth":150,heartbeat:150,"html5.unsupportedads":5,"fmt.noneavailable":5,"fmt.decode":5,"fmt.unplayable":5,"html5.missingapi":5,"html5.unsupportedlive":5,"drm.unavailable":5};function Ah(a,b){E.call(this);this.l=this.i=a;this.aa=b;this.C=!1;this.f={};this.ra=this.W=null;this.ca=new H;Xb(this,oa(G,this.ca));this.h={};this.j=this.Ha=this.g=this.zb=this.b=null;this.ja=!1;this.D=this.o=this.K=this.L=null;this.bb={};this.Zc=["onReady"];this.ka=new bg(this);Xb(this,oa(G,this.ka));this.Ab=null;this.$b=NaN;this.la={};Bh(this);this.na("onDetailedError",w(this.Hd,this));this.na("onTabOrderChange",w(this.bd,this));this.na("onTabAnnounce",w(this.ac,this));this.na("WATCH_LATER_VIDEO_ADDED",
w(this.Id,this));this.na("WATCH_LATER_VIDEO_REMOVED",w(this.Jd,this));rf||(this.na("onMouseWheelCapture",w(this.Ed,this)),this.na("onMouseWheelRelease",w(this.Fd,this)));this.na("onAdAnnounce",w(this.ac,this));this.G=new bg(this);Xb(this,oa(G,this.G));this.yb=!1;this.xb=null}
y(Ah,E);var Ch=["drm.unavailable","fmt.noneavailable","html5.missingapi","html5.unsupportedads","html5.unsupportedlive"];g=Ah.prototype;g.Wb=function(a,b){this.isDisposed()||(Dh(this,a),Eh(this,b),this.C&&Fh(this))};
function Dh(a,b){a.zb=b;a.b=b.clone();a.g=a.b.attrs.id||a.g;"video-player"==a.g&&(a.g=a.aa,a.b.attrs.id=a.aa);a.l.id==a.g&&(a.g+="-player",a.b.attrs.id=a.g);a.b.args.enablejsapi="1";a.b.args.playerapiid=a.aa;a.Ha||(a.Ha=Gh(a,a.b.args.jsapicallback||"onYouTubePlayerReady"));a.b.args.jsapicallback=null;var c=a.b.attrs.width;c&&(a.l.style.width=kf(Number(c)||c,!0));if(c=a.b.attrs.height)a.l.style.height=kf(Number(c)||c,!0)}
g.jd=function(){return this.zb};
function Fh(a){a.b.loaded||(a.b.loaded=!0,"0"!=a.b.args.autoplay?a.f.loadVideoByPlayerVars(a.b.args):a.f.cueVideoByPlayerVars(a.b.args))}
function Hh(a){if(!p(a.b.disable.flash)){var b=a.b.disable,c;c=Hf(Gf.getInstance(),a.b.minVersion);b.flash=!c}return!a.b.disable.flash}
function Ih(a,b){if((!b||(5!=(zh[b.errorCode]||5)?0:-1!=Ch.indexOf(b.errorCode)))&&Hh(a)){var c=Jh(a);c&&c.stopVideo&&c.stopVideo();var d=a.b;c&&c.getUpdatedConfigurationData&&(c=c.getUpdatedConfigurationData(),d=cf(c));d.args.autoplay=1;d.args.html5_unavailable="1";Dh(a,d);Eh(a,"flash")}}
function Eh(a,b){if(!a.isDisposed()){if(!b){var c;if(!(c=!a.b.html5&&Hh(a))){if(!p(a.b.disable.html5)){var d;c=!0;void 0!=a.b.args.deviceHasDisplay&&(c=a.b.args.deviceHasDisplay);if(2.2==Uf)d=!0;else{a:{var e=c;c=r("yt.player.utils.videoElement_");c||(c=document.createElement("video"),q("yt.player.utils.videoElement_",c,void 0));try{if(c.canPlayType)for(var e=e?$f:ag,f=0;f<e.length;f++)if(c.canPlayType(e[f])){d=null;break a}d="fmt.noneavailable"}catch(h){d="html5.missingapi"}}d=!d}d&&(d=Kh(a)||a.b.assets.js);
a.b.disable.html5=!d;d||(a.b.args.html5_unavailable="1")}c=!!a.b.disable.html5}b=c?Hh(a)?"flash":"unsupported":"html5"}("flash"==b?a.qe:"html5"==b?a.re:a.se).call(a)}}
function Kh(a){var b=!0,c=Jh(a);c&&a.b&&(a=a.b,b=C(c,"version")==a.assets.js);return b&&!!r("yt.player.Application.create")}
g.re=function(){if(!this.ja){var a=Kh(this);a&&"html5"==Lh(this)?(this.j="html5",this.C||this.Ma()):(Mh(this),this.j="html5",a&&this.K?(this.i.appendChild(this.K),this.Ma()):(this.b.loaded=!0,this.L=w(function(){var a=this.i,c=this.b.clone();r("yt.player.Application.create")(a,c);this.Ma()},this),this.ja=!0,a?this.L():(uc(this.b.assets.js,this.L),Pf(this.b.assets.css))))}};
g.qe=function(){var a=this.b.clone();if(!this.o){var b=Jh(this);b&&(this.o=document.createElement("span"),this.o.tabIndex=0,cg(this.ka,this.o,"focus",this.nc),this.D=document.createElement("span"),this.D.tabIndex=0,cg(this.ka,this.D,"focus",this.nc),b.parentNode&&b.parentNode.insertBefore(this.o,b),b.parentNode&&b.parentNode.insertBefore(this.D,b.nextSibling))}a.attrs.width=a.attrs.width||"100%";a.attrs.height=a.attrs.height||"100%";if("flash"==Lh(this))this.j="flash",this.C||Lf(a,!1,w(this.Ma,this));
else{Mh(this);this.j="flash";this.b.loaded=!0;b=this.i;b=u(b)?pe(b):b;a=cf(a);if(window!=window.top){var c=null;document.referrer&&(c=document.referrer.substring(0,128));a.args.framer=c}c=Gf.getInstance();Hf(c,a.minVersion)?(c=Mf(a,c),Kf(b,c,a)):Of(b,a,c);this.Ma()}};
g.nc=function(){Jh(this).focus()};
function Jh(a){var b=oe(a.g);!b&&a.l&&a.l.querySelector&&(b=a.l.querySelector("#"+a.g));return b}
g.Ma=function(){if(!this.isDisposed()){var a=Jh(this),b=!1;try{a&&a.getApiInterface&&a.getApiInterface()&&(b=!0)}catch(f){}if(b)if(this.ja=!1,a.isNotServable&&a.isNotServable(this.b.args.video_id))Ih(this);else{Bh(this);this.C=!0;a=Jh(this);a.addEventListener&&(this.W=Nh(this,a,"addEventListener"));a.removeEventListener&&(this.ra=Nh(this,a,"removeEventListener"));for(var b=a.getApiInterface(),b=b.concat(a.getInternalApiInterface()),c=0;c<b.length;c++){var d=b[c];this.f[d]||(this.f[d]=Nh(this,a,d))}for(var e in this.h)this.W(e,
this.h[e]);Fh(this);this.Ha&&this.Ha(this.f);this.ca.u("onReady",this.f)}else this.$b=J(w(this.Ma,this),50)}};
function Nh(a,b,c){var d=b[c];return function(){try{return a.Ab=null,d.apply(b,arguments)}catch(e){"Bad NPObject as private data!"!=e.message&&"sendAbandonmentPing"!=c&&(e.message+=" ("+c+")",a.Ab=e,ec(e,"WARNING"))}}}
function Bh(a){a.C=!1;if(a.ra)for(var b in a.h)a.ra(b,a.h[b]);for(var c in a.la)K(parseInt(c,10));a.la={};a.W=null;a.ra=null;for(var d in a.f)a.f[d]=null;a.f.addEventListener=w(a.na,a);a.f.removeEventListener=w(a.de,a);a.f.destroy=w(a.dispose,a);a.f.getLastError=w(a.kd,a);a.f.getPlayerType=w(a.ld,a);a.f.getCurrentVideoConfig=w(a.jd,a);a.f.loadNewVideoConfig=w(a.Wb,a);a.f.isReady=w(a.Ee,a)}
g.Ee=function(){return this.C};
g.na=function(a,b){if(!this.isDisposed()){var c=Gh(this,b);if(c){if(!Pa(this.Zc,a)&&!this.h[a]){var d=Oh(this,a);this.W&&this.W(a,d)}this.ca.subscribe(a,c);"onReady"==a&&this.C&&J(oa(c,this.f),0)}}};
g.de=function(a,b){if(!this.isDisposed()){var c=Gh(this,b);c&&this.ca.unsubscribe(a,c)}};
function Gh(a,b){var c=b;if("string"==typeof b){if(a.bb[b])return a.bb[b];c=function(){var a=r(b);a&&a.apply(m,arguments)};
a.bb[b]=c}return c?c:null}
function Oh(a,b){var c="ytPlayer"+b+a.aa;a.h[b]=c;m[c]=function(c){var e=J(function(){if(!a.isDisposed()){a.ca.u(b,c);var f=a.la,h=String(e);h in f&&delete f[h]}},0);
jb(a.la,String(e))};
return c}
g.bd=function(a){a=a?xe:we;for(var b=a(document.activeElement);b&&(1!=b.nodeType||b==this.o||b==this.D||(b.focus(),b!=document.activeElement));)b=a(b)};
g.ac=function(a){qc("a11y-announce",a)};
g.Hd=function(a){Ih(this,a)};
g.Id=function(a){qc("WATCH_LATER_VIDEO_ADDED",a)};
g.Jd=function(a){qc("WATCH_LATER_VIDEO_REMOVED",a)};
g.Ed=function(){this.yb||(vf?(this.xb=ue(document),cg(this.G,window,"scroll",this.Zd),cg(this.G,this.i,"touchmove",this.Td)):(cg(this.G,this.i,"mousewheel",this.qc),cg(this.G,this.i,"wheel",this.qc)),this.yb=!0)};
g.Fd=function(){dg(this.G);this.yb=!1};
g.qc=function(a){a=a||window.event;a.returnValue=!1;a.preventDefault&&a.preventDefault()};
g.Zd=function(){window.scrollTo(this.xb.x,this.xb.y)};
g.Td=function(a){a.preventDefault()};
g.se=function(){Mh(this);this.j="unsupported";var a='Adobe Flash Player or an HTML5 supported browser is required for video playback. <br> <a href="http://get.adobe.com/flashplayer/">Get the latest Flash Player</a> <br> <a href="/html5">Learn more about upgrading to an HTML5 browser</a>',b=navigator.userAgent.match(/Version\/(\d).*Safari/);b&&5<=parseInt(b[1],10)&&(a='Adobe Flash Player or QuickTime is required for video playback. <br> <a href="http://get.adobe.com/flashplayer/"> Get the latest Flash Player</a> <br> <a href="http://www.apple.com/quicktime/download/">Get the latest version of QuickTime</a>');
b=this.b.messages.player_fallback||a;a=oe("player-unavailable");if(oe("unavailable-submessage")&&a){oe("unavailable-submessage").innerHTML=b;var b=a||document,c=null;b.getElementsByClassName?c=b.getElementsByClassName("icon")[0]:b.querySelectorAll&&b.querySelector?c=b.querySelector(".icon"):c=re("icon",a)[0];if(c=b=c||null)c=b?b.dataset?Gb("icon")in b.dataset:b.hasAttribute?!!b.hasAttribute("data-icon"):!!b.getAttribute("data-icon"):!1;c&&(b.src=C(b,"icon"));a.style.display="";ee(oe("player"),"off-screen-trigger")}};
g.ld=function(){return this.j||Lh(this)};
g.kd=function(){return this.Ab};
function Lh(a){return(a=Jh(a))?"div"==a.tagName.toLowerCase()?"html5":"flash":null}
function Mh(a){ph("dcp");a.cancel();Bh(a);a.j=null;a.b&&(a.b.loaded=!1);var b=Jh(a);"html5"==Lh(a)?a.K=b:b&&b.destroy&&b.destroy();ve(a.i);dg(a.ka);a.o=null;a.D=null}
g.cancel=function(){this.L&&Bc(this.b.assets.js,this.L);K(this.$b);this.ja=!1};
g.w=function(){Mh(this);if(this.K&&this.b)try{this.K.destroy()}catch(b){ec(b)}this.bb=null;for(var a in this.h)m[this.h[a]]=null;this.zb=this.b=this.f=null;delete this.i;delete this.l;Ah.A.w.call(this)};var Ph={},Qh="player_uid_"+(1E9*Math.random()>>>0);function Rh(a,b){a=u(a)?pe(a):a;b=cf(b);var c=Qh+"_"+ia(a),d=Ph[c];if(d)return d.Wb(b),d.f;d=new Ah(a,c);Ph[c]=d;qc("player-added",d.f);Xb(d,oa(Sh,d));J(function(){d.Wb(b)},0);
return d.f}
function Sh(a){Ph[a.aa]=null}
function Th(a){a=oe(a);if(!a)return null;var b=Qh+"_"+ia(a),c=Ph[b];c||(c=new Ah(a,b),Ph[b]=c);return c.f}
;var Uh=r("yt.abuse.botguardInitialized")||Ec;q("yt.abuse.botguardInitialized",Uh,void 0);var Vh=r("yt.abuse.invokeBotguard")||Fc;q("yt.abuse.invokeBotguard",Vh,void 0);var Wh=r("yt.abuse.dclkstatus.checkDclkStatus")||be;q("yt.abuse.dclkstatus.checkDclkStatus",Wh,void 0);var Xh=r("yt.player.exports.navigate")||Ye;q("yt.player.exports.navigate",Xh,void 0);var Yh=r("yt.player.embed")||Rh;q("yt.player.embed",Yh,void 0);var Zh=r("yt.player.getPlayerByElement")||Th;q("yt.player.getPlayerByElement",Zh,void 0);
var $h=r("yt.util.activity.init")||Pe;q("yt.util.activity.init",$h,void 0);var ai=r("yt.util.activity.getTimeSinceActive")||Re;q("yt.util.activity.getTimeSinceActive",ai,void 0);var bi=r("yt.util.activity.setTimestamp")||Qe;q("yt.util.activity.setTimestamp",bi,void 0);function ci(a){P.call(this,1,arguments);this.b=a}
y(ci,P);function di(a){P.call(this,1,arguments);this.b=a}
y(di,P);function ei(a,b){P.call(this,1,arguments);this.b=a;this.isEnabled=b}
y(ei,P);function fi(a,b,c,d,e){P.call(this,2,arguments);this.f=a;this.b=b;this.h=c||null;this.g=d||null;this.source=e||null}
y(fi,P);function gi(a,b,c){P.call(this,1,arguments);this.b=a;this.subscriptionId=b}
y(gi,P);function hi(a,b,c,d,e,f,h){P.call(this,1,arguments);this.f=a;this.subscriptionId=b;this.b=c;this.i=d||null;this.h=e||null;this.g=f||null;this.source=h||null}
y(hi,P);
var ii=new Q("subscription-batch-subscribe",ci),ji=new Q("subscription-batch-unsubscribe",ci),ki=new Q("subscription-pref-email",ei),li=new Q("subscription-subscribe",fi),mi=new Q("subscription-subscribe-loading",di),ni=new Q("subscription-subscribe-loaded",di),oi=new Q("subscription-subscribe-success",gi),pi=new Q("subscription-subscribe-external",fi),qi=new Q("subscription-unsubscribe",hi),ri=new Q("subscription-unsubscirbe-loading",di),si=new Q("subscription-unsubscribe-loaded",di),ti=new Q("subscription-unsubscribe-success",
di),ui=new Q("subscription-external-unsubscribe",hi),vi=new Q("subscription-enable-ypc",di),wi=new Q("subscription-disable-ypc",di);function xi(a,b){var c=document.location.protocol+"//"+document.domain+"/post_login";b&&(c=Gd(c,"mode",b));c=Gd("/signin?context=popup","next",c);c=Gd(c,"feature","sub_button");if(c=window.open(c,"loginPopup","width=375,height=440,resizable=yes,scrollbars=yes",!0)){var d=nc("LOGGED_IN",function(b){pc(I("LOGGED_IN_PUBSUB_KEY",void 0));bc("LOGGED_IN",!0);a(b)});
bc("LOGGED_IN_PUBSUB_KEY",d);c.moveTo((screen.width-375)/2,(screen.height-440)/2)}}
q("yt.pubsub.publish",qc,void 0);function yi(){var a=I("PLAYER_CONFIG");return a&&a.args&&void 0!==a.args.authuser?!0:!(!I("SESSION_INDEX")&&!I("LOGGED_IN"))}
;var zi={},Ai="ontouchstart"in document;function Bi(a,b,c){var d;switch(a){case "mouseover":case "mouseout":d=3;break;case "mouseenter":case "mouseleave":d=9}return Fe(c,function(a){return de(a,b)},!0,d)}
function Ci(a){var b="mouseover"==a.type&&"mouseenter"in zi||"mouseout"==a.type&&"mouseleave"in zi,c=a.type in zi||b;if("HTML"!=a.target.tagName&&c){if(b){var b="mouseover"==a.type?"mouseenter":"mouseleave",c=zi[b],d;for(d in c.$){var e=Bi(b,d,a.target);e&&!Fe(a.relatedTarget,function(a){return a==e},!0)&&c.u(d,e,b,a)}}if(b=zi[a.type])for(d in b.$)(e=Bi(a.type,d,a.target))&&b.u(d,e,a.type,a)}}
N(document,"blur",Ci,!0);N(document,"change",Ci,!0);N(document,"click",Ci);N(document,"focus",Ci,!0);N(document,"mouseover",Ci);N(document,"mouseout",Ci);N(document,"mousedown",Ci);N(document,"keydown",Ci);N(document,"keyup",Ci);N(document,"keypress",Ci);N(document,"cut",Ci);N(document,"paste",Ci);Ai&&(N(document,"touchstart",Ci),N(document,"touchend",Ci),N(document,"touchcancel",Ci));function Di(a){this.i=a;this.g={};this.nb=[];this.h=[]}
function T(a,b){return"yt-uix"+(a.i?"-"+a.i:"")+(b?"-"+b:"")}
Di.prototype.unregister=function(){pc(this.nb);this.nb.length=0;bh(this.h);this.h.length=0};
Di.prototype.init=t;Di.prototype.dispose=t;function Ei(a,b,c){a.h.push(ah(b,c,a))}
function Fi(a,b,c){var d=T(a,void 0),e=w(c,a);b in zi||(zi[b]=new H);zi[b].subscribe(d,e);a.g[c]=e}
function Gi(a,b,c){if(b in zi){var d=zi[b];d.unsubscribe(T(a,void 0),a.g[c]);0>=d.N()&&(d.dispose(),delete zi[b])}delete a.g[c]}
function Hi(a,b){Fb(a,"tooltip-text",b)}
;function Ii(){Di.call(this,"tooltip");this.b=0;this.f={}}
y(Ii,Di);ba(Ii);g=Ii.prototype;g.register=function(){Fi(this,"mouseover",this.kb);Fi(this,"mouseout",this.Da);Fi(this,"focus",this.hc);Fi(this,"blur",this.cc);Fi(this,"click",this.Da);Fi(this,"touchstart",this.Ic);Fi(this,"touchend",this.rb);Fi(this,"touchcancel",this.rb)};
g.unregister=function(){Gi(this,"mouseover",this.kb);Gi(this,"mouseout",this.Da);Gi(this,"focus",this.hc);Gi(this,"blur",this.cc);Gi(this,"click",this.Da);Gi(this,"touchstart",this.Ic);Gi(this,"touchend",this.rb);Gi(this,"touchcancel",this.rb);this.dispose();Ii.A.unregister.call(this)};
g.dispose=function(){for(var a in this.f)this.Da(this.f[a]);this.f={}};
g.kb=function(a){if(!(this.b&&1E3>x()-this.b)){var b=parseInt(C(a,"tooltip-hide-timer"),10);b&&(Hb(a,"tooltip-hide-timer"),K(b));var b=w(function(){Ji(this,a);Hb(a,"tooltip-show-timer")},this),c=parseInt(C(a,"tooltip-show-delay"),10)||0,b=J(b,c);
Fb(a,"tooltip-show-timer",b.toString());a.title&&(Hi(a,Ki(a)),a.title="");b=ia(a).toString();this.f[b]=a}};
g.Da=function(a){var b=parseInt(C(a,"tooltip-show-timer"),10);b&&(K(b),Hb(a,"tooltip-show-timer"));b=w(function(){if(a){var b=oe(Li(this,a));b&&(Mi(b),b&&b.parentNode&&b.parentNode.removeChild(b),Hb(a,"content-id"));(b=oe(Li(this,a,"arialabel")))&&b.parentNode&&b.parentNode.removeChild(b)}Hb(a,"tooltip-hide-timer")},this);
b=J(b,50);Fb(a,"tooltip-hide-timer",b.toString());if(b=C(a,"tooltip-text"))a.title=b;b=ia(a).toString();delete this.f[b]};
g.hc=function(a){this.b=0;this.kb(a)};
g.cc=function(a){this.b=0;this.Da(a)};
g.Ic=function(a,b,c){c.changedTouches&&(this.b=0,a=Bi(b,T(this),c.changedTouches[0].target),this.kb(a))};
g.rb=function(a,b,c){c.changedTouches&&(this.b=x(),a=Bi(b,T(this),c.changedTouches[0].target),this.Da(a))};
function Ni(a,b){Hi(a,b);var c=C(a,"content-id");(c=oe(c))&&ye(c,b)}
function Ki(a){return C(a,"tooltip-text")||a.title}
function Ji(a,b){if(b){var c=Ki(b);if(c){var d=oe(Li(a,b));if(!d){d=document.createElement("div");d.id=Li(a,b);d.className=T(a,"tip");var e=document.createElement("div");e.className=T(a,"tip-body");var f=document.createElement("div");f.className=T(a,"tip-arrow");var h=document.createElement("div");h.setAttribute("aria-hidden","true");h.className=T(a,"tip-content");var k=Oi(a,b),l=Li(a,b,"content");h.id=l;Fb(b,"content-id",l);e.appendChild(h);k&&d.appendChild(k);d.appendChild(e);d.appendChild(f);var l=
Be(b),n=Li(a,b,"arialabel"),f=document.createElement("div");ee(f,T(a,"arialabel"));f.id=n;"rtl"==document.body.getAttribute("dir")?ye(f,c+" "+l):ye(f,l+" "+c);b.setAttribute("aria-labelledby",n);l=Je()||document.body;l.appendChild(f);l.appendChild(d);Ni(b,c);(c=parseInt(C(b,"tooltip-max-width"),10))&&e.offsetWidth>c&&(e.style.width=c+"px",ee(h,T(a,"normal-wrap")));h=de(b,T(a,"reverse"));Pi(a,b,d,e,k,h)||Pi(a,b,d,e,k,!h);var D=T(a,"tip-visible");J(function(){ee(d,D)},0)}}}}
function Pi(a,b,c,d,e,f){ge(c,T(a,"tip-reverse"),f);var h=0;f&&(h=1);a=lf(b);f=new he((a.width-10)/2,f?a.height:0);var k=ne(b),l=new he(0,0),n;n=k?ne(k):document;n=!L||nd(9)||te(ke(n).b)?n.documentElement:n.body;b!=n&&(n=jf(b),k=ue(ke(k).b),l.x=n.left+k.x,l.y=n.top+k.y);f=new he(l.x+f.x,l.y+f.y);f=f.clone();l=(h&8&&"rtl"==hf(c,"direction")?h^4:h)&-9;h=lf(c);k=h.clone();n=f.clone();k=k.clone();0!=l&&(l&4?n.x-=k.width+0:l&2&&(n.x-=k.width/2),l&1&&(n.y-=k.height+0));f=new ef(0,0,0,0);f.left=n.x;f.top=
n.y;f.width=k.width;f.height=k.height;k=new he(f.left,f.top);k instanceof he?(l=k.x,k=k.y):(l=k,k=void 0);c.style.left=kf(l,!1);c.style.top=kf(k,!1);k=new ie(f.width,f.height);if(!(h==k||h&&k&&h.width==k.width&&h.height==k.height))if(h=k,f=ne(c),l=te(ke(f).b),!L||md("10")||l&&md("8"))f=c.style,bd?f.MozBoxSizing="border-box":cd?f.WebkitBoxSizing="border-box":f.boxSizing="border-box",f.width=Math.max(h.width,0)+"px",f.height=Math.max(h.height,0)+"px";else if(f=c.style,l){if(L){l=of(c,"paddingLeft");
k=of(c,"paddingRight");n=of(c,"paddingTop");var D=of(c,"paddingBottom"),l=new df(n,k,D,l)}else l=gf(c,"paddingLeft"),k=gf(c,"paddingRight"),n=gf(c,"paddingTop"),D=gf(c,"paddingBottom"),l=new df(parseFloat(n),parseFloat(k),parseFloat(D),parseFloat(l));if(L&&!nd(9)){k=qf(c,"borderLeft");n=qf(c,"borderRight");var D=qf(c,"borderTop"),v=qf(c,"borderBottom"),k=new df(D,n,v,k)}else k=gf(c,"borderLeftWidth"),n=gf(c,"borderRightWidth"),D=gf(c,"borderTopWidth"),v=gf(c,"borderBottomWidth"),k=new df(parseFloat(D),
parseFloat(n),parseFloat(v),parseFloat(k));f.pixelWidth=h.width-k.left-l.left-l.right-k.right;f.pixelHeight=h.height-k.top-l.top-l.bottom-k.bottom}else f.pixelWidth=h.width,f.pixelHeight=h.height;f=se(window);1==c.nodeType?(c=jf(c),k=new he(c.left,c.top)):(c=c.changedTouches?c.changedTouches[0]:c,k=new he(c.clientX,c.clientY));c=lf(d);n=Math.floor(c.width/2);h=!!(f.height<k.y+a.height);a=!!(k.y<a.height);l=!!(k.x<n);f=!!(f.width<k.x+n);k=(c.width+3)/-2- -5;b=C(b,"force-tooltip-direction");if("left"==
b||l)k=-5;else if("right"==b||f)k=20-c.width-3;b=Math.floor(k)+"px";d.style.left=b;e&&(e.style.left=b,e.style.height=c.height+"px",e.style.width=c.width+"px");return!(h||a)}
function Li(a,b,c){a=T(a);var d=b.__yt_uid_key;d||(d=He(),b.__yt_uid_key=d);b=a+d;c&&(b+="-"+c);return b}
function Oi(a,b){var c=null;ed&&de(b,T(a,"masked"))&&((c=oe("yt-uix-tooltip-shared-mask"))?(c.parentNode.removeChild(c),Ef(c)):(c=document.createElement("iframe"),c.src='javascript:""',c.id="yt-uix-tooltip-shared-mask",c.className=T(a,"tip-mask")));return c}
function Mi(a){var b=oe("yt-uix-tooltip-shared-mask"),c=b&&Fe(b,function(b){return b==a},!1,2);
b&&c&&(b.parentNode.removeChild(b),Ff(b),document.body.appendChild(b))}
;function Qi(){Di.call(this,"subscription-button")}
y(Qi,Di);ba(Qi);Qi.prototype.register=function(){Fi(this,"click",this.Eb);Ei(this,mi,this.pc);Ei(this,ni,this.oc);Ei(this,oi,this.Rd);Ei(this,ri,this.pc);Ei(this,si,this.oc);Ei(this,ti,this.Xd);Ei(this,vi,this.Dd);Ei(this,wi,this.Cd)};
Qi.prototype.unregister=function(){Gi(this,"click",this.Eb);Qi.A.unregister.call(this)};
var Ee={Xb:"hover-enabled",Rc:"yt-uix-button-subscribe",Sc:"yt-uix-button-subscribed",Ge:"ypc-enabled",Tc:"yt-uix-button-subscription-container",Uc:"yt-subscription-button-disabled-mask-container"},Ri={He:"channel-external-id",Vc:"subscriber-count-show-when-subscribed",Wc:"subscriber-count-tooltip",Xc:"subscriber-count-title",Ie:"href",Yb:"is-subscribed",Ke:"parent-url",Me:"clicktracking",Yc:"style-type",Zb:"subscription-id",Pe:"target",$c:"ypc-enabled"};g=Qi.prototype;
g.Eb=function(a){var b=C(a,"href"),c=yi();if(b)a=C(a,"target")||"_self",window.open(b,a);else if(c){var b=C(a,"channel-external-id"),c=C(a,"clicktracking"),d;if(C(a,"ypc-enabled")){d=C(a,"ypc-item-type");var e=C(a,"ypc-item-id");d={itemType:d,itemId:e,subscriptionElement:a}}else d=null;e=C(a,"parent-url");if(C(a,"is-subscribed")){var f=C(a,"subscription-id");R(qi,new hi(b,f,d,a,c,e))}else R(li,new fi(b,d,c,e))}else Si(this,a)};
g.pc=function(a){this.Ia(a.b,this.Fc,!0)};
g.oc=function(a){this.Ia(a.b,this.Fc,!1)};
g.Rd=function(a){this.Ia(a.b,this.Gc,!0,a.subscriptionId)};
g.Xd=function(a){this.Ia(a.b,this.Gc,!1)};
g.Dd=function(a){this.Ia(a.b,this.ed)};
g.Cd=function(a){this.Ia(a.b,this.dd)};
g.Gc=function(a,b,c){b?(Fb(a,Ri.Yb,"true"),c&&Fb(a,Ri.Zb,c)):(Hb(a,Ri.Yb),Hb(a,Ri.Zb));Ti(a)};
g.Fc=function(a,b){var c;c=De(a);ge(c,Ee.Uc,b);a.setAttribute("aria-busy",b?"true":"false");a.disabled=b};
function Ti(a){var b=C(a,Ri.Yc),c=!!C(a,"is-subscribed"),b="-"+b,d=Ee.Sc+b;ge(a,Ee.Rc+b,!c);ge(a,d,c);C(a,Ri.Wc)&&!C(a,Ri.Vc)&&(b=T(Ii.getInstance()),ge(a,b,!c),a.title=c?"":C(a,Ri.Xc));c?J(function(){ee(a,Ee.Xb)},1E3):fe(a,Ee.Xb)}
g.ed=function(a){var b=!!C(a,"ypc-item-type"),c=!!C(a,"ypc-item-id");!C(a,"ypc-enabled")&&b&&c&&(ee(a,"ypc-enabled"),Fb(a,Ri.$c,"true"))};
g.dd=function(a){C(a,"ypc-enabled")&&(fe(a,"ypc-enabled"),Hb(a,"ypc-enabled"))};
function Ui(a,b){var c=qe(T(a));return Ja(c,function(a){return b==C(a,"channel-external-id")},a)}
g.ad=function(a,b,c){var d=Xa(arguments,2);A(a,function(a){b.apply(this,Ta(a,d))},this)};
g.Ia=function(a,b,c){var d=Ui(this,a),d=Ta([d],Xa(arguments,1));this.ad.apply(this,d)};
function Si(a,b){var c=w(function(a){a.discoverable_subscriptions&&bc("SUBSCRIBE_EMBED_DISCOVERABLE_SUBSCRIPTIONS",a.discoverable_subscriptions);this.Eb(b)},a);
xi(c,"subscribe")}
;var Vi=window.yt&&window.yt.uix&&window.yt.uix.widgets_||{};q("yt.uix.widgets_",Vi,void 0);function Wi(a,b){this.source=null;this.h=a||null;this.origin="*";this.o=window.document.location.protocol+"//"+window.document.location.hostname;this.l=b;this.g=this.b=this.f=this.i=null;N(window,"message",w(this.j,this))}
Wi.prototype.j=function(a){var b=this.l||I("POST_MESSAGE_ORIGIN",void 0)||this.o;if("*"!=b&&a.origin!=b)window.console&&window.console.warn("Untrusted origin: "+a.origin);else if(!this.h||a.source==this.h)if(this.source=a.source,this.origin="null"==a.origin?this.origin:a.origin,a=a.data,u(a)){try{a=qd(a)}catch(c){return}this.i=a.id;switch(a.event){case "listening":this.b&&(this.b(),this.b=null);break;case "command":this.f&&(this.g&&!Pa(this.g,a.func)||this.f(a.func,a.args))}}};
Wi.prototype.sendMessage=function(a){this.source&&(a.id=this.i,a=M(a),this.source.postMessage(a,this.origin))};function Xi(){}
;function Yi(){}
y(Yi,Xi);Yi.prototype.N=function(){var a=0;Kc(this.ma(!0),function(){a++});
return a};
Yi.prototype.clear=function(){var a=Lc(this.ma(!0)),b=this;A(a,function(a){b.remove(a)})};function Zi(a){this.b=a}
y(Zi,Yi);g=Zi.prototype;g.isAvailable=function(){if(!this.b)return!1;try{return this.b.setItem("__sak","1"),this.b.removeItem("__sak"),!0}catch(a){return!1}};
g.set=function(a,b){try{this.b.setItem(a,b)}catch(c){if(0==this.b.length)throw"Storage mechanism: Storage disabled";throw"Storage mechanism: Quota exceeded";}};
g.get=function(a){a=this.b.getItem(a);if(!u(a)&&null!==a)throw"Storage mechanism: Invalid value was encountered";return a};
g.remove=function(a){this.b.removeItem(a)};
g.N=function(){return this.b.length};
g.ma=function(a){var b=0,c=this.b,d=new Ic;d.next=function(){if(b>=c.length)throw Hc;var d=c.key(b++);if(a)return d;d=c.getItem(d);if(!u(d))throw"Storage mechanism: Invalid value was encountered";return d};
return d};
g.clear=function(){this.b.clear()};
g.key=function(a){return this.b.key(a)};function $i(){var a=null;try{a=window.localStorage||null}catch(b){}this.b=a}
y($i,Zi);function aj(){var a=null;try{a=window.sessionStorage||null}catch(b){}this.b=a}
y(aj,Zi);function bj(a){this.b=a}
bj.prototype.set=function(a,b){p(b)?this.b.set(a,M(b)):this.b.remove(a)};
bj.prototype.get=function(a){var b;try{b=this.b.get(a)}catch(c){return}if(null!==b)try{return qd(b)}catch(c){throw"Storage: Invalid value was encountered";}};
bj.prototype.remove=function(a){this.b.remove(a)};function cj(a){this.b=a}
y(cj,bj);function dj(a){this.data=a}
function ej(a){return!p(a)||a instanceof dj?a:new dj(a)}
cj.prototype.set=function(a,b){cj.A.set.call(this,a,ej(b))};
cj.prototype.f=function(a){a=cj.A.get.call(this,a);if(!p(a)||a instanceof Object)return a;throw"Storage: Invalid value was encountered";};
cj.prototype.get=function(a){if(a=this.f(a)){if(a=a.data,!p(a))throw"Storage: Invalid value was encountered";}else a=void 0;return a};function fj(a){this.b=a}
y(fj,cj);function gj(a){var b=a.creation;a=a.expiration;return!!a&&a<x()||!!b&&b>x()}
fj.prototype.set=function(a,b,c){if(b=ej(b)){if(c){if(c<x()){fj.prototype.remove.call(this,a);return}b.expiration=c}b.creation=x()}fj.A.set.call(this,a,b)};
fj.prototype.f=function(a,b){var c=fj.A.f.call(this,a);if(c)if(!b&&gj(c))fj.prototype.remove.call(this,a);else return c};function hj(a){this.b=a}
y(hj,fj);function ij(a,b){var c=[];Kc(b,function(a){var b;try{b=hj.prototype.f.call(this,a,!0)}catch(f){if("Storage: Invalid value was encountered"==f)return;throw f;}p(b)?gj(b)&&c.push(a):c.push(a)},a);
return c}
function jj(a,b){var c=ij(a,b);A(c,function(a){hj.prototype.remove.call(this,a)},a)}
function kj(){var a=lj;jj(a,a.b.ma(!0))}
;function U(a,b,c){var d=c&&0<c?c:0;c=d?x()+1E3*d:0;if((d=d?lj:mj)&&window.JSON){u(b)||(b=JSON.stringify(b,void 0));try{d.set(a,b,c)}catch(e){d.remove(a)}}}
function nj(a){if(!mj&&!lj||!window.JSON)return null;var b;try{b=mj.get(a)}catch(c){}if(!u(b))try{b=lj.get(a)}catch(c){}if(!u(b))return null;try{b=JSON.parse(b,void 0)}catch(c){}return b}
function oj(a){mj&&mj.remove(a);lj&&lj.remove(a)}
var lj,pj=new $i;lj=pj.isAvailable()?new hj(pj):null;var mj,qj=new aj;mj=qj.isAvailable()?new hj(qj):null;function rj(a){return(0==a.search("cue")||0==a.search("load"))&&"loadModule"!=a}
function sj(a,b,c){u(a)&&(a={mediaContentUrl:a,startSeconds:b,suggestedQuality:c});b=a;c=/\/([ve]|embed)\/([^#?]+)/.exec(a.mediaContentUrl);b.videoId=c&&c[2]?c[2]:null;return tj(a)}
function tj(a,b,c){if(ha(a)){b="endSeconds startSeconds mediaContentUrl suggestedQuality videoId two_stage_token".split(" ");c={};for(var d=0;d<b.length;d++){var e=b[d];a[e]&&(c[e]=a[e])}return c}return{videoId:a,startSeconds:b,suggestedQuality:c}}
function uj(a,b,c,d){if(ha(a)&&!da(a)){b="playlist list listType index startSeconds suggestedQuality".split(" ");c={};for(d=0;d<b.length;d++){var e=b[d];a[e]&&(c[e]=a[e])}return c}c={index:b,startSeconds:c,suggestedQuality:d};u(a)&&16==a.length?c.list="PL"+a:c.playlist=a;return c}
function vj(a){var b=a.video_id||a.videoId;if(u(b)){var c=nj("yt-player-two-stage-token")||{},d=nj("yt-player-two-stage-token")||{};p(void 0)?d[b]=void 0:delete d[b];U("yt-player-two-stage-token",d,300);(b=c[b])&&(a.two_stage_token=b)}}
;function wj(){var a=window.navigator.userAgent.match(/Chrome\/([0-9]+)/);return a?50<=parseInt(a[1],10):!1}
var xj=document.currentScript&&-1!=document.currentScript.src.indexOf("?loadGamesSDK")?"/cast_game_sender.js":"/cast_sender.js",yj=["boadgeojelhgndaghljhdicfkmllpafd","dliochdbjfkdbacpmhlcpmleaejidimm","enhhojjnijigcajfphajepfemndkmdlo","fmfcbgogabcbclcofgocippekhfcmgfj"],zj=["pkedcjkdefgpdelpbcmbmeomcjbeemfm","fjhoaacokmgbjemoflkofnenfaiekifl"],Aj=wj()?zj.concat(yj):yj.concat(zj);function Bj(a,b){var c=new XMLHttpRequest;c.onreadystatechange=function(){4==c.readyState&&200==c.status&&b(!0)};
c.onerror=function(){b(!1)};
try{c.open("GET",a,!0),c.send()}catch(d){b(!1)}}
function Cj(a){if(a>=Aj.length)Dj();else{var b=Aj[a],c="chrome-extension://"+b+xj;0<=yj.indexOf(b)?Bj(c,function(d){d?(window.chrome.cast=window.chrome.cast||{},window.chrome.cast.extensionId=b,Ej(c,Dj)):Cj(a+1)}):Ej(c,function(){Cj(a+1)})}}
function Ej(a,b){var c=document.createElement("script");c.onerror=b;c.src=a;(document.head||document.documentElement).appendChild(c)}
function Dj(){var a=window.__onGCastApiAvailable;a&&"function"==typeof a&&a(!1,"No cast extension found")}
function Fj(){if(0<=window.navigator.userAgent.indexOf("CriOS")){var a=window.__gCrWeb&&window.__gCrWeb.message&&window.__gCrWeb.message.invokeOnHost;if(a){a({command:"cast.sender.init"});return}}window.chrome?(a=window.navigator.userAgent,0<=a.indexOf("Android")&&0<=a.indexOf("Chrome/")&&window.navigator.presentation?(a=wj()?"50":"",Ej("//www.gstatic.com/eureka/clank"+a+xj,Dj)):Cj(0)):Dj()}
;var Gj=x(),Hj=null,Ij=Array(50),Jj=-1,Kj=!1;function Lj(){var a=Mj;Nj();Hj.push(a);Oj(Hj)}
function Pj(a,b){Nj();var c=Hj,d=Qj(a,String(b));0==c.length?Rj(d):(Oj(c),A(c,function(a){a(d)}))}
function Nj(){Hj||(Hj=r("yt.mdx.remote.debug.handlers_")||[],q("yt.mdx.remote.debug.handlers_",Hj,void 0))}
function Rj(a){var b=(Jj+1)%50;Jj=b;Ij[b]=a;Kj||(Kj=49==b)}
function Oj(a){var b=Ij;if(b[0]){var c=Jj,d=Kj?c:-1;do{var d=(d+1)%50,e=b[d];A(a,function(a){a(e)})}while(d!=c);
Ij=Array(50);Jj=-1;Kj=!1}}
function Qj(a,b){var c=(x()-Gj)/1E3;c.toFixed&&(c=c.toFixed(3));var d=[];d.push("[",c+"s","] ");d.push("[","yt.mdx.remote","] ");d.push(a+": "+b,"\n");return d.join("")}
;function Sj(a){a=a||{};this.name=a.name||"";this.id=a.id||a.screenId||"";this.token=a.token||a.loungeToken||"";this.uuid=a.uuid||a.dialId||""}
function Tj(a,b){return!!b&&(a.id==b||a.uuid==b)}
function Uj(a){return{name:a.name,screenId:a.id,loungeToken:a.token,dialId:a.uuid}}
function Vj(a){return new Sj(a)}
function Wj(a){return da(a)?Ka(a,Vj):[]}
function Xj(a){return a?'{name:"'+a.name+'",id:'+a.id.substr(0,6)+"..,token:"+(a.token?".."+a.token.slice(-6):"-")+",uuid:"+(a.uuid?".."+a.uuid.slice(-6):"-")+"}":"null"}
function Yj(a){return da(a)?"["+Ka(a,Xj).join(",")+"]":"null"}
;var Zj={Fe:"atp",Oe:"ska",Le:"que",Je:"mus",Ne:"sus"};function ak(a){this.h=this.g="";this.b="/api/lounge";this.f=!0;a=a||document.location.href;var b=Number(a.match(yd)[4]||null)||null||"";b&&(this.h=":"+b);this.g=zd(a)||"";a=ob;0<=a.search("MSIE")&&(a=a.match(/MSIE ([\d.]+)/)[1],0>Fa(a,"10.0")&&(this.f=!1))}
function bk(a,b,c,d){var e=a.b;if(p(d)?d:a.f)e="https://"+a.g+a.h+a.b;return Hd(e+b,c||{})}
function ck(a,b,c,d,e){a={format:"JSON",method:"POST",context:a,timeout:5E3,withCredentials:!1,Z:oa(a.l,d,!0),onError:oa(a.i,e),Ea:oa(a.j,e)};c&&(a.J=c,a.headers={"Content-Type":"application/x-www-form-urlencoded"});return Rd(b,a)}
ak.prototype.l=function(a,b,c,d){b?a(d):a({text:c.responseText})};
ak.prototype.i=function(a,b){a(Error("Request error: "+b.status))};
ak.prototype.j=function(a){a(Error("request timed out"))};function dk(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(a){var b=16*Math.random()|0;return("x"==a?b:b&3|8).toString(16)})}
function ek(a,b){return Na(a,function(a){return a.key==b})}
function fk(a){return Ka(a,function(a){return{key:a.id,name:a.name}})}
function gk(a,b){return Na(a,function(a){return a||b?!a!=!b?!1:a.id==b.id:!0})}
function hk(a,b){return Na(a,function(a){return Tj(a,b)})}
;function V(){E.call(this);this.l=new H;Xb(this,oa(G,this.l))}
y(V,E);V.prototype.subscribe=function(a,b,c){return this.isDisposed()?0:this.l.subscribe(a,b,c)};
V.prototype.unsubscribe=function(a,b,c){return this.isDisposed()?!1:this.l.unsubscribe(a,b,c)};
V.prototype.ha=function(a){return this.isDisposed()?!1:this.l.ha(a)};
V.prototype.u=function(a,b){return this.isDisposed()?!1:this.l.u.apply(this.l,arguments)};function ik(a){V.call(this);this.j=a;this.screens=[]}
y(ik,V);ik.prototype.S=function(){return this.screens};
ik.prototype.contains=function(a){return!!gk(this.screens,a)};
ik.prototype.get=function(a){return a?hk(this.screens,a):null};
function jk(a,b){var c=a.get(b.uuid)||a.get(b.id);if(c){var d=c.name;c.id=b.id||c.id;c.name=b.name;c.token=b.token;c.uuid=b.uuid||c.uuid;return c.name!=d}a.screens.push(b);return!0}
function kk(a,b){var c=a.screens.length!=b.length;a.screens=Ja(a.screens,function(a){return!!gk(b,a)});
for(var d=0,e=b.length;d<e;d++)c=jk(a,b[d])||c;return c}
function lk(a,b){var c=a.screens.length;a.screens=Ja(a.screens,function(a){return!(a||b?!a!=!b?0:a.id==b.id:1)});
return a.screens.length<c}
ik.prototype.info=function(a){Pj(this.j,a)};function mk(a,b,c,d){V.call(this);this.o=a;this.j=b;this.h=c;this.i=d;this.g=0;this.b=null;this.f=NaN}
y(mk,V);var nk=[2E3,2E3,1E3,1E3,1E3,2E3,2E3,5E3,5E3,1E4];g=mk.prototype;g.start=function(){!this.b&&isNaN(this.f)&&this.Ac()};
g.stop=function(){this.b&&(this.b.abort(),this.b=null);isNaN(this.f)||(K(this.f),this.f=NaN)};
g.w=function(){this.stop();mk.A.w.call(this)};
g.Ac=function(){this.f=NaN;this.b=Rd(bk(this.o,"/pairing/get_screen"),{method:"POST",J:{pairing_code:this.j},timeout:5E3,Z:w(this.we,this),onError:w(this.ve,this),Ea:w(this.xe,this)})};
g.we=function(a,b){this.b=null;var c=b.screen||{};c.dialId=this.h;c.name=this.i;this.u("pairingComplete",new Sj(c))};
g.ve=function(a){this.b=null;a.status&&404==a.status?this.g>=nk.length?this.u("pairingFailed",Error("DIAL polling timed out")):(a=nk[this.g],this.f=J(w(this.Ac,this),a),this.g++):this.u("pairingFailed",Error("Server error "+a.status))};
g.xe=function(){this.b=null;this.u("pairingFailed",Error("Server not responding"))};function ok(a){this.app=this.name=this.id="";this.type="REMOTE_CONTROL";this.avatar=this.username="";this.capabilities=new Vc;this.experiments=new Vc;this.theme="u";if(a){this.id=a.id||a.name;this.name=a.name;this.app=a.app;this.type=a.type||"REMOTE_CONTROL";this.username=a.user||"";this.avatar=a.userAvatarUri||"";this.theme=a.theme||"u";var b=a.capabilities||"";this.capabilities.clear();Wc(this.capabilities,Ja(b.split(","),oa(bb,Zj)));a=a.experiments||"";this.experiments.clear();Wc(this.experiments,
a.split(","))}}
ok.prototype.equals=function(a){return a?this.id==a.id:!1};var pk;function qk(){var a=rk(),b=sk();Pa(a,b);if(tk()){var c=a,d;d=0;for(var e=c.length,f;d<e;){var h=d+e>>1,k;k=Ya(b,c[h]);0<k?d=h+1:(e=h,f=!k)}d=f?d:~d;0>d&&Wa(c,-(d+1),0,b)}a=uk(a);if(0==a.length)try{We.remove("remote_sid","/","youtube.com")}catch(l){}else try{Xe("remote_sid",a.join(","),-1)}catch(l){}}
function rk(){var a=nj("yt-remote-connected-devices")||[];a.sort(Ya);return a}
function uk(a){if(0==a.length)return[];var b=a[0].indexOf("#"),c=-1==b?a[0]:a[0].substring(0,b);return Ka(a,function(a,b){return 0==b?a:a.substring(c.length)})}
function vk(a){U("yt-remote-connected-devices",a,86400)}
function sk(){if(wk)return wk;var a=nj("yt-remote-device-id");a||(a=dk(),U("yt-remote-device-id",a,31536E3));for(var b=rk(),c=1,d=a;Pa(b,d);)c++,d=a+"#"+c;return wk=d}
function xk(){return nj("yt-remote-session-browser-channel")}
function tk(){return nj("yt-remote-session-screen-id")}
function yk(a){5<a.length&&(a=a.slice(a.length-5));var b=Ka(zk(),function(a){return a.loungeToken}),c=Ka(a,function(a){return a.loungeToken});
Ma(c,function(a){return!Pa(b,a)})&&Ak();
U("yt-remote-local-screens",a,31536E3)}
function zk(){return nj("yt-remote-local-screens")||[]}
function Ak(){U("yt-remote-lounge-token-expiration",!0,86400)}
function Bk(a,b){U("yt-remote-session-browser-channel",a);U("yt-remote-session-screen-id",b);var c=rk(),d=sk();Pa(c,d)||c.push(d);vk(c);qk()}
function Ck(a){a||(oj("yt-remote-session-screen-id"),oj("yt-remote-session-video-id"));qk();a=rk();Ra(a,sk());vk(a)}
function Dk(){if(!pk){var a;a=new $i;(a=a.isAvailable()?a:null)&&(pk=new bj(a))}return pk?!!pk.get("yt-remote-use-staging-server"):!1}
var wk="";function Ek(a){ik.call(this,"LocalScreenService");this.f=a;this.b=NaN;Fk(this);this.info("Initializing with "+Yj(this.screens))}
y(Ek,ik);g=Ek.prototype;g.start=function(){Fk(this)&&this.u("screenChange");!nj("yt-remote-lounge-token-expiration")&&Gk(this);K(this.b);this.b=J(w(this.start,this),1E4)};
g.wb=function(a,b){Fk(this);jk(this,a);Hk(this,!1);this.u("screenChange");b(a);a.token||Gk(this)};
g.remove=function(a,b){var c=Fk(this);lk(this,a)&&(Hk(this,!1),c=!0);b(a);c&&this.u("screenChange")};
g.tb=function(a,b,c,d){var e=Fk(this),f=this.get(a.id);f?(f.name!=b&&(f.name=b,Hk(this,!1),e=!0),c(a)):d(Error("no such local screen."));e&&this.u("screenChange")};
g.w=function(){K(this.b);Ek.A.w.call(this)};
function Gk(a){if(a.screens.length){var b=Ka(a.screens,function(a){return a.id}),c=bk(a.f,"/pairing/get_lounge_token_batch");
ck(a.f,c,{screen_ids:b.join(",")},w(a.od,a),w(a.nd,a))}}
g.od=function(a){Fk(this);var b=this.screens.length;a=a&&a.screens||[];for(var c=0,d=a.length;c<d;++c){var e=a[c],f=this.get(e.screenId);f&&(f.token=e.loungeToken,--b)}Hk(this,!b);b&&Pj(this.j,"Missed "+b+" lounge tokens.")};
g.nd=function(a){Pj(this.j,"Requesting lounge tokens failed: "+a)};
function Fk(a){var b=Wj(zk()),b=Ja(b,function(a){return!a.uuid});
return kk(a,b)}
function Hk(a,b){yk(Ka(a.screens,Uj));b&&Ak()}
;function Ik(a,b){V.call(this);this.i=b;for(var c=nj("yt-remote-online-screen-ids")||"",c=c?c.split(","):[],d={},e=this.i(),f=0,h=e.length;f<h;++f){var k=e[f].id;d[k]=Pa(c,k)}this.b=d;this.j=a;this.g=this.h=NaN;this.f=null;Jk("Initialized with "+M(this.b))}
y(Ik,V);g=Ik.prototype;g.start=function(){var a=parseInt(nj("yt-remote-fast-check-period")||"0",10);(this.h=x()-144E5<a?0:a)?Kk(this):(this.h=x()+3E5,U("yt-remote-fast-check-period",this.h),this.Rb())};
g.isEmpty=function(){return ib(this.b)};
g.update=function(){Jk("Updating availability on schedule.");var a=this.i(),b=$a(this.b,function(b,d){return b&&!!hk(a,d)},this);
Lk(this,b)};
function Mk(a,b,c){var d=bk(a.j,"/pairing/get_screen_availability");ck(a.j,d,{lounge_token:b.token},w(function(a){a=a.screens||[];for(var d=0,h=a.length;d<h;++d)if(a[d].loungeToken==b.token){c("online"==a[d].status);return}c(!1)},a),w(function(){c(!1)},a))}
g.w=function(){K(this.g);this.g=NaN;this.f&&(this.f.abort(),this.f=null);Ik.A.w.call(this)};
function Lk(a,b){var c;a:if(ab(b)!=ab(a.b))c=!1;else{c=eb(b);for(var d=0,e=c.length;d<e;++d)if(!a.b[c[d]]){c=!1;break a}c=!0}c||(Jk("Updated online screens: "+M(a.b)),a.b=b,a.u("screenChange"));Nk(a)}
function Kk(a){isNaN(a.g)||K(a.g);a.g=J(w(a.Rb,a),0<a.h&&a.h<x()?2E4:1E4)}
g.Rb=function(){K(this.g);this.g=NaN;this.f&&this.f.abort();var a=Ok(this);if(ab(a)){var b=bk(this.j,"/pairing/get_screen_availability");this.f=ck(this.j,b,{lounge_token:eb(a).join(",")},w(this.Pd,this,a),w(this.Od,this))}else Lk(this,{}),Kk(this)};
g.Pd=function(a,b){this.f=null;var c;a:{c=eb(Ok(this));var d=eb(a);if(ea(c)&&ea(d)&&c.length==d.length){for(var e=c.length,f=0;f<e;f++)if(c[f]!==d[f]){c=!1;break a}c=!0}else c=!1}if(c){c=b.screens||[];d={};e=0;for(f=c.length;e<f;++e)d[a[c[e].loungeToken]]="online"==c[e].status;Lk(this,d);Kk(this)}else this.H("Changing Screen set during request."),this.Rb()};
g.Od=function(a){this.H("Screen availability failed: "+a);this.f=null;Kk(this)};
function Jk(a){Pj("OnlineScreenService",a)}
g.H=function(a){Pj("OnlineScreenService",a)};
function Ok(a){var b={};A(a.i(),function(a){a.token?b[a.token]=a.id:this.H("Requesting availability of screen w/o lounge token.")});
return b}
function Nk(a){var b=eb($a(a.b,function(a){return a}));
b.sort(Ya);b.length?U("yt-remote-online-screen-ids",b.join(","),60):oj("yt-remote-online-screen-ids");a=Ja(a.i(),function(a){return!!this.b[a.id]},a);
U("yt-remote-online-screens",Ka(a,Uj),60)}
;function W(a){ik.call(this,"ScreenService");this.i=a;this.b=this.f=null;this.g=[];this.h={};Pk(this)}
y(W,ik);g=W.prototype;g.start=function(){this.f.start();this.b.start();this.screens.length&&(this.u("screenChange"),this.b.isEmpty()||this.u("onlineScreenChange"))};
g.wb=function(a,b,c){this.f.wb(a,b,c)};
g.remove=function(a,b,c){this.f.remove(a,b,c);this.b.update()};
g.tb=function(a,b,c,d){this.f.contains(a)?this.f.tb(a,b,c,d):(a="Updating name of unknown screen: "+a.name,Pj(this.j,a),d(Error(a)))};
g.S=function(a){return a?this.screens:Ta(this.screens,Ja(this.g,function(a){return!this.contains(a)},this))};
g.Lc=function(){return Ja(this.S(!0),function(a){return!!this.b.b[a.id]},this)};
function Qk(a,b,c,d,e,f){a.info("getAutomaticScreenByIds "+c+" / "+b);c||(c=a.h[b]);var h=a.S();if(h=(c?hk(h,c):null)||hk(h,b)){h.uuid=b;var k=Rk(a,h);Mk(a.b,k,function(a){e(a?k:null)})}else c?Sk(a,c,w(function(a){var f=Rk(this,new Sj({name:d,
screenId:c,loungeToken:a,dialId:b||""}));Mk(this.b,f,function(a){e(a?f:null)})},a),f):e(null)}
g.Mc=function(a,b,c,d,e){this.info("getDialScreenByPairingCode "+a+" / "+b);var f=new mk(this.i,a,b,c);f.subscribe("pairingComplete",w(function(a){G(f);d(Rk(this,a))},this));
f.subscribe("pairingFailed",function(a){G(f);e(a)});
f.start();return w(f.stop,f)};
function Tk(a,b){for(var c=0,d=a.screens.length;c<d;++c)if(a.screens[c].name==b)return a.screens[c];return null}
g.ze=function(a,b,c,d){Rd(bk(this.i,"/pairing/get_screen"),{method:"POST",J:{pairing_code:a},timeout:5E3,Z:w(function(a,d){var h=new Sj(d.screen||{});if(!h.name||Tk(this,h.name)){var k;a:{k=h.name;for(var l=2,n=b(k,l);Tk(this,n);){l++;if(20<l)break a;n=b(k,l)}k=n}h.name=k}c(Rk(this,h))},this),
onError:w(function(a){d(Error("pairing request failed: "+a.status))},this),
Ea:w(function(){d(Error("pairing request timed out."))},this)})};
g.w=function(){G(this.f);G(this.b);W.A.w.call(this)};
function Sk(a,b,c,d){a.info("requestLoungeToken_ for "+b);var e={J:{screen_ids:b},method:"POST",context:a,Z:function(a,e){var k=e&&e.screens||[];k[0]&&k[0].screenId==b?c(k[0].loungeToken):d(Error("Missing lounge token in token response"))},
onError:function(){d(Error("Request screen lounge token failed"))}};
Rd(bk(a.i,"/pairing/get_lounge_token_batch"),e)}
function Uk(a){a.screens=a.f.S();var b=a.h,c={},d;for(d in b)c[b[d]]=d;b=0;for(d=a.screens.length;b<d;++b){var e=a.screens[b];e.uuid=c[e.id]||""}a.info("Updated manual screens: "+Yj(a.screens))}
g.pd=function(){Uk(this);this.u("screenChange");this.b.update()};
function Pk(a){Vk(a);a.f=new Ek(a.i);a.f.subscribe("screenChange",w(a.pd,a));Uk(a);a.g=Wj(nj("yt-remote-automatic-screen-cache")||[]);Vk(a);a.info("Initializing automatic screens: "+Yj(a.g));a.b=new Ik(a.i,w(a.S,a,!0));a.b.subscribe("screenChange",w(function(){this.u("onlineScreenChange")},a))}
function Rk(a,b){var c=a.get(b.id);c?(c.uuid=b.uuid,b=c):((c=hk(a.g,b.uuid))?(c.id=b.id,c.token=b.token,b=c):a.g.push(b),U("yt-remote-automatic-screen-cache",Ka(a.g,Uj)));Vk(a);a.h[b.uuid]=b.id;U("yt-remote-device-id-map",a.h,31536E3);return b}
function Vk(a){a.h=nj("yt-remote-device-id-map")||{}}
W.prototype.dispose=W.prototype.dispose;function Wk(a,b,c){V.call(this);this.L=c;this.D=a;this.f=b;this.g=null}
y(Wk,V);g=Wk.prototype;g.mb=function(a){this.g=a;this.u("sessionScreen",this.g)};
g.T=function(a){this.isDisposed()||(a&&Xk(this,""+a),this.g=null,this.u("sessionScreen",null))};
g.info=function(a){Pj(this.L,a)};
function Xk(a,b){Pj(a.L,b)}
g.Oc=function(){return null};
g.Tb=function(a){var b=this.f;a?(b.displayStatus=new chrome.cast.ReceiverDisplayStatus(a,[]),b.displayStatus.showStop=!0):b.displayStatus=null;chrome.cast.setReceiverDisplayStatus(b,w(function(){this.info("Updated receiver status for "+b.friendlyName+": "+a)},this),w(function(){Xk(this,"Failed to update receiver status for: "+b.friendlyName)},this))};
g.w=function(){this.Tb("");Wk.A.w.call(this)};function Yk(a,b){Wk.call(this,a,b,"CastSession");this.b=null;this.i=0;this.h=null;this.o=w(this.Ae,this);this.j=w(this.$d,this);this.i=J(w(function(){Zk(this,null)},this),12E4)}
y(Yk,Wk);g=Yk.prototype;g.Sb=function(a){if(this.b){if(this.b==a)return;Xk(this,"Overriding cast sesison with new session object");this.b.removeUpdateListener(this.o);this.b.removeMessageListener("urn:x-cast:com.google.youtube.mdx",this.j)}this.b=a;this.b.addUpdateListener(this.o);this.b.addMessageListener("urn:x-cast:com.google.youtube.mdx",this.j);this.h&&$k(this);al(this,"getMdxSessionStatus")};
g.La=function(a){this.info("launchWithParams: "+M(a));this.h=a;this.b&&$k(this)};
g.stop=function(){this.b?this.b.stop(w(function(){this.T()},this),w(function(){this.T(Error("Failed to stop receiver app."))},this)):this.T(Error("Stopping cast device witout session."))};
g.Tb=t;g.w=function(){this.info("disposeInternal");K(this.i);this.i=0;this.b&&(this.b.removeUpdateListener(this.o),this.b.removeMessageListener("urn:x-cast:com.google.youtube.mdx",this.j));this.b=null;Yk.A.w.call(this)};
function $k(a){var b=a.h.videoId;b&&al(a,"flingVideo",{videoId:b,currentTime:a.h.currentTime||0});a.h=null}
function al(a,b,c){a.info("sendYoutubeMessage_: "+b+" "+M(c));var d={};d.type=b;c&&(d.data=c);a.b?a.b.sendMessage("urn:x-cast:com.google.youtube.mdx",d,t,w(function(){Xk(this,"Failed to send message: "+b+".")},a)):Xk(a,"Sending yt message without session: "+M(d))}
g.$d=function(a,b){if(!this.isDisposed())if(b){var c=rd(b);if(c){var d=""+c.type,c=c.data||{};this.info("onYoutubeMessage_: "+d+" "+M(c));switch(d){case "mdxSessionStatus":Zk(this,c.screenId);break;default:Xk(this,"Unknown youtube message: "+d)}}else Xk(this,"Unable to parse message.")}else Xk(this,"No data in message.")};
function Zk(a,b){K(a.i);if(b){if(a.info("onConnectedScreenId_: Received screenId: "+b),!a.g||a.g.id!=b){var c=w(a.mb,a),d=w(a.T,a);a.jc(b,c,d,5)}}else a.T(Error("Waiting for session status timed out."))}
g.jc=function(a,b,c,d){Qk(this.D,this.f.label,a,this.f.friendlyName,w(function(e){e?b(e):0<=d?(Xk(this,"Screen "+a+" appears to be offline. "+d+" retries left."),J(w(this.jc,this,a,b,c,d-1),300)):c(Error("Unable to fetch screen."))},this),c)};
g.Oc=function(){return this.b};
g.Ae=function(a){this.isDisposed()||a||(Xk(this,"Cast session died."),this.T())};function bl(a,b){Wk.call(this,a,b,"DialSession");this.h=this.C=null;this.G="";this.i=null;this.o=t;this.j=NaN;this.K=w(this.De,this);this.b=t}
y(bl,Wk);g=bl.prototype;g.Sb=function(a){this.h=a;this.h.addUpdateListener(this.K)};
g.La=function(a){this.i=a;this.o()};
g.stop=function(){this.b();this.b=t;K(this.j);this.h?this.h.stop(w(this.T,this,null),w(this.T,this,"Failed to stop DIAL device.")):this.T()};
g.w=function(){this.b();this.b=t;K(this.j);this.h&&this.h.removeUpdateListener(this.K);this.h=null;bl.A.w.call(this)};
function cl(a){a.b=a.D.Mc(a.G,a.f.label,a.f.friendlyName,w(function(a){this.b=t;this.mb(a)},a),w(function(a){this.b=t;
this.T(a)},a))}
g.De=function(a){this.isDisposed()||a||(Xk(this,"DIAL session died."),this.b(),this.b=t,this.T())};
function dl(a){var b={};b.pairingCode=a.G;if(a.i){var c=a.i.currentTime||0;b.v=a.i.videoId;b.t=c}Dk()&&(b.env_useStageMdx=1);return Fd(b)}
g.Ob=function(a){this.G=dk();if(this.i){var b=new chrome.cast.DialLaunchResponse(!0,dl(this));a(b);cl(this)}else this.o=w(function(){K(this.j);this.o=t;this.j=NaN;var b=new chrome.cast.DialLaunchResponse(!0,dl(this));a(b);cl(this)},this),this.j=J(w(function(){this.o()},this),100)};
g.qd=function(a,b){Qk(this.D,this.C.receiver.label,a,this.f.friendlyName,w(function(a){a&&a.token?(this.mb(a),b(new chrome.cast.DialLaunchResponse(!1))):this.Ob(b)},this),w(function(a){Xk(this,"Failed to get DIAL screen: "+a);
this.Ob(b)},this))};function el(a,b){Wk.call(this,a,b,"ManualSession");this.b=J(w(this.La,this,null),150)}
y(el,Wk);el.prototype.stop=function(){this.T()};
el.prototype.Sb=t;el.prototype.La=function(){K(this.b);this.b=NaN;var a=hk(this.D.S(),this.f.label);a?this.mb(a):this.T(Error("No such screen"))};
el.prototype.w=function(){K(this.b);this.b=NaN;el.A.w.call(this)};function X(a){V.call(this);this.f=a;this.b=null;this.i=!1;this.g=[];this.h=w(this.Md,this)}
y(X,V);g=X.prototype;
g.init=function(a,b){chrome.cast.timeout.requestSession=3E4;var c=new chrome.cast.SessionRequest("233637DE");c.dialRequest=new chrome.cast.DialRequest("YouTube");var d=chrome.cast.AutoJoinPolicy.TAB_AND_ORIGIN_SCOPED,e=a?chrome.cast.DefaultActionPolicy.CAST_THIS_TAB:chrome.cast.DefaultActionPolicy.CREATE_SESSION,c=new chrome.cast.ApiConfig(c,w(this.uc,this),w(this.Nd,this),d,e);c.customDialLaunchCallback=w(this.Bd,this);chrome.cast.initialize(c,w(function(){this.isDisposed()||(chrome.cast.addReceiverActionListener(this.h),
Lj(),this.f.subscribe("onlineScreenChange",w(this.Nc,this)),this.g=fl(this),chrome.cast.setCustomReceivers(this.g,t,w(function(a){this.H("Failed to set initial custom receivers: "+M(a))},this)),this.u("yt-remote-cast2-availability-change",gl(this)),b(!0))},this),w(function(a){this.H("Failed to initialize API: "+M(a));
b(!1)},this))};
g.me=function(a,b){hl("Setting connected screen ID: "+a+" -> "+b);if(this.b){var c=this.b.g;if(!a||c&&c.id!=a)hl("Unsetting old screen status: "+this.b.f.friendlyName),G(this.b),this.b=null}if(a&&b){if(!this.b){c=hk(this.f.S(),a);if(!c){hl("setConnectedScreenStatus: Unknown screen.");return}var d=il(this,c);d||(hl("setConnectedScreenStatus: Connected receiver not custom..."),d=new chrome.cast.Receiver(c.uuid?c.uuid:c.id,c.name),d.receiverType=chrome.cast.ReceiverType.CUSTOM,this.g.push(d),chrome.cast.setCustomReceivers(this.g,
t,w(function(a){this.H("Failed to set initial custom receivers: "+M(a))},this)));
hl("setConnectedScreenStatus: new active receiver: "+d.friendlyName);jl(this,new el(this.f,d),!0)}this.b.Tb(b)}else hl("setConnectedScreenStatus: no screen.")};
function il(a,b){return b?Na(a.g,function(a){return Tj(b,a.label)},a):null}
g.ne=function(a){this.isDisposed()?this.H("Setting connection data on disposed cast v2"):this.b?this.b.La(a):this.H("Setting connection data without a session")};
g.Ce=function(){this.isDisposed()?this.H("Stopping session on disposed cast v2"):this.b?(this.b.stop(),G(this.b),this.b=null):hl("Stopping non-existing session")};
g.requestSession=function(){chrome.cast.requestSession(w(this.uc,this),w(this.Qd,this))};
g.w=function(){this.f.unsubscribe("onlineScreenChange",w(this.Nc,this));window.chrome&&chrome.cast&&chrome.cast.removeReceiverActionListener(this.h);var a=Mj,b=r("yt.mdx.remote.debug.handlers_");Ra(b||[],a);G(this.b);X.A.w.call(this)};
function hl(a){Pj("Controller",a)}
g.H=function(a){Pj("Controller",a)};
function Mj(a){window.chrome&&chrome.cast&&chrome.cast.logMessage&&chrome.cast.logMessage(a)}
function gl(a){return a.i||!!a.g.length||!!a.b}
function jl(a,b,c){G(a.b);(a.b=b)?(c?a.u("yt-remote-cast2-receiver-resumed",b.f):a.u("yt-remote-cast2-receiver-selected",b.f),b.subscribe("sessionScreen",w(a.wc,a,b)),b.g?a.u("yt-remote-cast2-session-change",b.g):c&&a.b.La(null)):a.u("yt-remote-cast2-session-change",null)}
g.wc=function(a,b){this.b==a&&(b||jl(this,null),this.u("yt-remote-cast2-session-change",b))};
g.Md=function(a,b){if(!this.isDisposed())if(a)switch(hl("onReceiverAction_ "+a.label+" / "+a.friendlyName+"-- "+b),b){case chrome.cast.ReceiverAction.CAST:if(this.b)if(this.b.f.label!=a.label)hl("onReceiverAction_: Stopping active receiver: "+this.b.f.friendlyName),this.b.stop();else{hl("onReceiverAction_: Casting to active receiver.");this.b.g&&this.u("yt-remote-cast2-session-change",this.b.g);break}switch(a.receiverType){case chrome.cast.ReceiverType.CUSTOM:jl(this,new el(this.f,a));break;case chrome.cast.ReceiverType.DIAL:jl(this,
new bl(this.f,a));break;case chrome.cast.ReceiverType.CAST:jl(this,new Yk(this.f,a));break;default:this.H("Unknown receiver type: "+a.receiverType)}break;case chrome.cast.ReceiverAction.STOP:this.b&&this.b.f.label==a.label?this.b.stop():this.H("Stopping receiver w/o session: "+a.friendlyName)}else this.H("onReceiverAction_ called without receiver.")};
g.Bd=function(a){if(this.isDisposed())return Promise.reject(Error("disposed"));var b=a.receiver;b.receiverType!=chrome.cast.ReceiverType.DIAL&&(this.H("Not DIAL receiver: "+b.friendlyName),b.receiverType=chrome.cast.ReceiverType.DIAL);var c=this.b?this.b.f:null;if(!c||c.label!=b.label)return this.H("Receiving DIAL launch request for non-clicked DIAL receiver: "+b.friendlyName),Promise.reject(Error("illegal DIAL launch"));if(c&&c.label==b.label&&c.receiverType!=chrome.cast.ReceiverType.DIAL){if(this.b.g)return hl("Reselecting dial screen."),
this.u("yt-remote-cast2-session-change",this.b.g),Promise.resolve(new chrome.cast.DialLaunchResponse(!1));this.H('Changing CAST intent from "'+c.receiverType+'" to "dial" for '+b.friendlyName);jl(this,new bl(this.f,b))}b=this.b;b.C=a;return b.C.appState==chrome.cast.DialAppState.RUNNING?new Promise(w(b.qd,b,(b.C.extraData||{}).screenId||null)):new Promise(w(b.Ob,b))};
g.uc=function(a){if(!this.isDisposed()){hl("New cast session ID: "+a.sessionId);var b=a.receiver;if(b.receiverType!=chrome.cast.ReceiverType.CUSTOM){if(!this.b)if(b.receiverType==chrome.cast.ReceiverType.CAST)hl("Got resumed cast session before resumed mdx connection."),jl(this,new Yk(this.f,b),!0);else{this.H("Got non-cast session without previous mdx receiver event, or mdx resume.");return}var c=this.b.f,d=hk(this.f.S(),c.label);d&&Tj(d,b.label)&&c.receiverType!=chrome.cast.ReceiverType.CAST&&b.receiverType==
chrome.cast.ReceiverType.CAST&&(hl("onSessionEstablished_: manual to cast session change "+b.friendlyName),G(this.b),this.b=new Yk(this.f,b),this.b.subscribe("sessionScreen",w(this.wc,this,this.b)),this.b.La(null));this.b.Sb(a)}}};
g.Be=function(){return this.b?this.b.Oc():null};
g.Qd=function(a){this.isDisposed()||(this.H("Failed to estabilish a session: "+M(a)),a.code!=chrome.cast.ErrorCode.CANCEL&&jl(this,null))};
g.Nd=function(a){hl("Receiver availability updated: "+a);if(!this.isDisposed()){var b=gl(this);this.i=a==chrome.cast.ReceiverAvailability.AVAILABLE;gl(this)!=b&&this.u("yt-remote-cast2-availability-change",gl(this))}};
function fl(a){var b=a.f.Lc(),c=a.b&&a.b.f;a=Ka(b,function(a){c&&Tj(a,c.label)&&(c=null);var b=a.uuid?a.uuid:a.id,f=il(this,a);f?(f.label=b,f.friendlyName=a.name):(f=new chrome.cast.Receiver(b,a.name),f.receiverType=chrome.cast.ReceiverType.CUSTOM);return f},a);
c&&(c.receiverType!=chrome.cast.ReceiverType.CUSTOM&&(c=new chrome.cast.Receiver(c.label,c.friendlyName),c.receiverType=chrome.cast.ReceiverType.CUSTOM),a.push(c));return a}
g.Nc=function(){if(!this.isDisposed()){var a=gl(this);this.g=fl(this);hl("Updating custom receivers: "+M(this.g));chrome.cast.setCustomReceivers(this.g,t,w(function(){this.H("Failed to set custom receivers.")},this));
var b=gl(this);b!=a&&this.u("yt-remote-cast2-availability-change",b)}};
X.prototype.setLaunchParams=X.prototype.ne;X.prototype.setConnectedScreenStatus=X.prototype.me;X.prototype.stopSession=X.prototype.Ce;X.prototype.getCastSession=X.prototype.Be;X.prototype.requestSession=X.prototype.requestSession;X.prototype.init=X.prototype.init;X.prototype.dispose=X.prototype.dispose;function kl(a,b,c){ll()?nl(a)&&(ol(!0),window.chrome&&chrome.cast&&chrome.cast.isAvailable?pl(b):(window.__onGCastApiAvailable=function(a,c){a?pl(b):(ql("Failed to load cast API: "+c),rl(!1),ol(!1),oj("yt-remote-cast-available"),oj("yt-remote-cast-receiver"),sl(),b(!1))},c?uc("https://www.gstatic.com/cv/js/sender/v1/cast_sender.js"):Fj())):ml("Cannot initialize because not running Chrome")}
function sl(){ml("dispose");var a=tl();a&&a.dispose();ul=null;q("yt.mdx.remote.cloudview.instance_",null,void 0);vl(!1);pc(wl);wl.length=0}
function xl(){return!!nj("yt-remote-cast-installed")}
function yl(){var a=nj("yt-remote-cast-receiver");a?(a=a.friendlyName,a=-1!=a.indexOf("&")?"document"in m?Aa(a):Ca(a):a):a=null;return a}
function zl(){ml("clearCurrentReciever");oj("yt-remote-cast-receiver")}
function Al(){xl()?tl()?Bl()?(ml("Requesting cast selector."),ul.requestSession()):(ml("Wait for cast API to be ready to request the session."),wl.push(nc("yt-remote-cast2-api-ready",Al))):ql("requestCastSelector: Cast is not initialized."):ql("requestCastSelector: Cast API is not installed!")}
function Cl(a){Bl()?tl().setLaunchParams(a):ql("setLaunchParams called before ready.")}
function Dl(a,b){Bl()?tl().setConnectedScreenStatus(a,b):ql("setConnectedScreenStatus called before ready.")}
var ul=null;function ll(){var a;a=0<=ob.search(/\ (CrMo|Chrome|CriOS)\//);return vf||a}
function nl(a){var b=!1;if(!ul){var c=r("yt.mdx.remote.cloudview.instance_");c||(c=new X(a),c.subscribe("yt-remote-cast2-availability-change",function(a){U("yt-remote-cast-available",a);qc("yt-remote-cast2-availability-change",a)}),c.subscribe("yt-remote-cast2-receiver-selected",function(a){ml("onReceiverSelected: "+a.friendlyName);
U("yt-remote-cast-receiver",a);qc("yt-remote-cast2-receiver-selected",a)}),c.subscribe("yt-remote-cast2-receiver-resumed",function(a){ml("onReceiverResumed: "+a.friendlyName);
U("yt-remote-cast-receiver",a)}),c.subscribe("yt-remote-cast2-session-change",function(a){ml("onSessionChange: "+Xj(a));
a||oj("yt-remote-cast-receiver");qc("yt-remote-cast2-session-change",a)}),q("yt.mdx.remote.cloudview.instance_",c,void 0),b=!0);
ul=c}ml("cloudview.createSingleton_: "+b);return b}
function tl(){ul||(ul=r("yt.mdx.remote.cloudview.instance_"));return ul}
function pl(a){rl(!0);ol(!1);ul.init(!0,function(b){b?(vl(!0),qc("yt-remote-cast2-api-ready")):(ql("Failed to initialize cast API."),rl(!1),oj("yt-remote-cast-available"),oj("yt-remote-cast-receiver"),sl());a(b)})}
function ml(a){Pj("cloudview",a)}
function ql(a){Pj("cloudview",a)}
function rl(a){ml("setCastInstalled_ "+a);U("yt-remote-cast-installed",a)}
function Bl(){return!!r("yt.mdx.remote.cloudview.apiReady_")}
function vl(a){ml("setApiReady_ "+a);q("yt.mdx.remote.cloudview.apiReady_",a,void 0)}
function ol(a){q("yt.mdx.remote.cloudview.initializing_",a,void 0)}
var wl=[];function El(){}
;function Fl(a,b){this.action=a;this.params=b||null}
;function Gl(){this.b=x()}
new Gl;Gl.prototype.set=function(a){this.b=a};
Gl.prototype.reset=function(){this.set(x())};
Gl.prototype.get=function(){return this.b};function Hl(a,b){this.type=a;this.currentTarget=this.target=b;this.defaultPrevented=this.b=!1;this.Dc=!0}
Hl.prototype.stopPropagation=function(){this.b=!0};
Hl.prototype.preventDefault=function(){this.defaultPrevented=!0;this.Dc=!1};var Il=!L||nd(9),Jl=L&&!md("9");!cd||md("528");bd&&md("1.9b")||L&&md("8")||$c&&md("9.5")||cd&&md("528");bd&&!md("8")||L&&md("9");function Kl(a,b){Hl.call(this,a?a.type:"");this.relatedTarget=this.currentTarget=this.target=null;this.charCode=this.keyCode=this.button=this.screenY=this.screenX=this.clientY=this.clientX=0;this.metaKey=this.shiftKey=this.altKey=this.ctrlKey=!1;this.f=this.state=null;a&&this.init(a,b)}
y(Kl,Hl);
Kl.prototype.init=function(a,b){var c=this.type=a.type,d=a.changedTouches?a.changedTouches[0]:null;this.target=a.target||a.srcElement;this.currentTarget=b;var e=a.relatedTarget;if(e){if(bd){var f;a:{try{ff(e.nodeName);f=!0;break a}catch(h){}f=!1}f||(e=null)}}else"mouseover"==c?e=a.fromElement:"mouseout"==c&&(e=a.toElement);this.relatedTarget=e;null===d?(this.clientX=void 0!==a.clientX?a.clientX:a.pageX,this.clientY=void 0!==a.clientY?a.clientY:a.pageY,this.screenX=a.screenX||0,this.screenY=a.screenY||
0):(this.clientX=void 0!==d.clientX?d.clientX:d.pageX,this.clientY=void 0!==d.clientY?d.clientY:d.pageY,this.screenX=d.screenX||0,this.screenY=d.screenY||0);this.button=a.button;this.keyCode=a.keyCode||0;this.charCode=a.charCode||("keypress"==c?a.keyCode:0);this.ctrlKey=a.ctrlKey;this.altKey=a.altKey;this.shiftKey=a.shiftKey;this.metaKey=a.metaKey;this.state=a.state;this.f=a;a.defaultPrevented&&this.preventDefault()};
Kl.prototype.stopPropagation=function(){Kl.A.stopPropagation.call(this);this.f.stopPropagation?this.f.stopPropagation():this.f.cancelBubble=!0};
Kl.prototype.preventDefault=function(){Kl.A.preventDefault.call(this);var a=this.f;if(a.preventDefault)a.preventDefault();else if(a.returnValue=!1,Jl)try{if(a.ctrlKey||112<=a.keyCode&&123>=a.keyCode)a.keyCode=-1}catch(b){}};var Ll="closure_listenable_"+(1E6*Math.random()|0),Ml=0;function Nl(a,b,c,d,e){this.listener=a;this.b=null;this.src=b;this.type=c;this.eb=!!d;this.ib=e;this.key=++Ml;this.Na=this.cb=!1}
function Ol(a){a.Na=!0;a.listener=null;a.b=null;a.src=null;a.ib=null}
;function Pl(a){this.src=a;this.b={};this.f=0}
function Ql(a,b,c,d,e){var f=b.toString();b=a.b[f];b||(b=a.b[f]=[],a.f++);var h=Rl(b,c,d,e);-1<h?(a=b[h],a.cb=!1):(a=new Nl(c,a.src,f,!!d,e),a.cb=!1,b.push(a));return a}
Pl.prototype.remove=function(a,b,c,d){a=a.toString();if(!(a in this.b))return!1;var e=this.b[a];b=Rl(e,b,c,d);return-1<b?(Ol(e[b]),Array.prototype.splice.call(e,b,1),0==e.length&&(delete this.b[a],this.f--),!0):!1};
function Sl(a,b){var c=b.type;c in a.b&&Ra(a.b[c],b)&&(Ol(b),0==a.b[c].length&&(delete a.b[c],a.f--))}
function Tl(a,b,c,d,e){a=a.b[b.toString()];b=-1;a&&(b=Rl(a,c,d,e));return-1<b?a[b]:null}
function Rl(a,b,c,d){for(var e=0;e<a.length;++e){var f=a[e];if(!f.Na&&f.listener==b&&f.eb==!!c&&f.ib==d)return e}return-1}
;var Ul="closure_lm_"+(1E6*Math.random()|0),Vl={},Wl=0;
function Xl(a,b,c,d,e){if(da(b)){for(var f=0;f<b.length;f++)Xl(a,b[f],c,d,e);return null}c=Yl(c);if(a&&a[Ll])a=a.jb(b,c,d,e);else{if(!b)throw Error("Invalid event type");var f=!!d,h=Zl(a);h||(a[Ul]=h=new Pl(a));c=Ql(h,b,c,d,e);if(!c.b){d=$l();c.b=d;d.src=a;d.listener=c;if(a.addEventListener)a.addEventListener(b.toString(),d,f);else if(a.attachEvent)a.attachEvent(am(b.toString()),d);else throw Error("addEventListener and attachEvent are unavailable.");Wl++}a=c}return a}
function $l(){var a=bm,b=Il?function(c){return a.call(b.src,b.listener,c)}:function(c){c=a.call(b.src,b.listener,c);
if(!c)return c};
return b}
function cm(a,b,c,d,e){if(da(b))for(var f=0;f<b.length;f++)cm(a,b[f],c,d,e);else c=Yl(c),a&&a[Ll]?a.sb(b,c,d,e):a&&(a=Zl(a))&&(b=Tl(a,b,c,!!d,e))&&dm(b)}
function dm(a){if(!fa(a)&&a&&!a.Na){var b=a.src;if(b&&b[Ll])Sl(b.g,a);else{var c=a.type,d=a.b;b.removeEventListener?b.removeEventListener(c,d,a.eb):b.detachEvent&&b.detachEvent(am(c),d);Wl--;(c=Zl(b))?(Sl(c,a),0==c.f&&(c.src=null,b[Ul]=null)):Ol(a)}}}
function am(a){return a in Vl?Vl[a]:Vl[a]="on"+a}
function em(a,b,c,d){var e=!0;if(a=Zl(a))if(b=a.b[b.toString()])for(b=b.concat(),a=0;a<b.length;a++){var f=b[a];f&&f.eb==c&&!f.Na&&(f=fm(f,d),e=e&&!1!==f)}return e}
function fm(a,b){var c=a.listener,d=a.ib||a.src;a.cb&&dm(a);return c.call(d,b)}
function bm(a,b){if(a.Na)return!0;if(!Il){var c=b||r("window.event"),d=new Kl(c,this),e=!0;if(!(0>c.keyCode||void 0!=c.returnValue)){a:{var f=!1;if(0==c.keyCode)try{c.keyCode=-1;break a}catch(l){f=!0}if(f||void 0==c.returnValue)c.returnValue=!0}c=[];for(f=d.currentTarget;f;f=f.parentNode)c.push(f);for(var f=a.type,h=c.length-1;!d.b&&0<=h;h--){d.currentTarget=c[h];var k=em(c[h],f,!0,d),e=e&&k}for(h=0;!d.b&&h<c.length;h++)d.currentTarget=c[h],k=em(c[h],f,!1,d),e=e&&k}return e}return fm(a,new Kl(b,this))}
function Zl(a){a=a[Ul];return a instanceof Pl?a:null}
var gm="__closure_events_fn_"+(1E9*Math.random()>>>0);function Yl(a){if(ga(a))return a;a[gm]||(a[gm]=function(b){return a.handleEvent(b)});
return a[gm]}
;function hm(){E.call(this);this.g=new Pl(this);this.ra=this;this.ca=null}
y(hm,E);hm.prototype[Ll]=!0;g=hm.prototype;g.addEventListener=function(a,b,c,d){Xl(this,a,b,c,d)};
g.removeEventListener=function(a,b,c,d){cm(this,a,b,c,d)};
function im(a,b){var c,d=a.ca;if(d){c=[];for(var e=1;d;d=d.ca)c.push(d),++e}var d=a.ra,e=b,f=e.type||e;if(u(e))e=new Hl(e,d);else if(e instanceof Hl)e.target=e.target||d;else{var h=e,e=new Hl(f,d);nb(e,h)}var h=!0,k;if(c)for(var l=c.length-1;!e.b&&0<=l;l--)k=e.currentTarget=c[l],h=jm(k,f,!0,e)&&h;e.b||(k=e.currentTarget=d,h=jm(k,f,!0,e)&&h,e.b||(h=jm(k,f,!1,e)&&h));if(c)for(l=0;!e.b&&l<c.length;l++)k=e.currentTarget=c[l],h=jm(k,f,!1,e)&&h}
g.w=function(){hm.A.w.call(this);if(this.g){var a=this.g,b=0,c;for(c in a.b){for(var d=a.b[c],e=0;e<d.length;e++)++b,Ol(d[e]);delete a.b[c];a.f--}}this.ca=null};
g.jb=function(a,b,c,d){return Ql(this.g,String(a),b,c,d)};
g.sb=function(a,b,c,d){return this.g.remove(String(a),b,c,d)};
function jm(a,b,c,d){b=a.g.b[String(b)];if(!b)return!0;b=b.concat();for(var e=!0,f=0;f<b.length;++f){var h=b[f];if(h&&!h.Na&&h.eb==c){var k=h.listener,l=h.ib||h.src;h.cb&&Sl(a.g,h);e=!1!==k.call(l,d)&&e}}return e&&0!=d.Dc}
;function km(a,b){this.f=new td(a);this.b=b?rd:qd}
km.prototype.stringify=function(a){return sd(this.f,a)};
km.prototype.parse=function(a){return this.b(a)};function lm(a,b){this.b=0;this.j=void 0;this.h=this.f=this.g=null;this.i=this.l=!1;if(a!=t)try{var c=this;a.call(b,function(a){mm(c,2,a)},function(a){mm(c,3,a)})}catch(d){mm(this,3,d)}}
function nm(){this.next=this.context=this.f=this.h=this.b=null;this.g=!1}
nm.prototype.reset=function(){this.context=this.f=this.h=this.b=null;this.g=!1};
var om=new Mb(function(){return new nm},function(a){a.reset()},100);
function pm(a,b,c){var d=om.get();d.h=a;d.f=b;d.context=c;return d}
function qm(a){return new lm(function(b,c){c(a)})}
lm.prototype.then=function(a,b,c){return rm(this,ga(a)?a:null,ga(b)?b:null,c)};
lm.prototype.then=lm.prototype.then;lm.prototype.$goog_Thenable=!0;lm.prototype.cancel=function(a){0==this.b&&Rb(function(){var b=new sm(a);tm(this,b)},this)};
function tm(a,b){if(0==a.b)if(a.g){var c=a.g;if(c.f){for(var d=0,e=null,f=null,h=c.f;h&&(h.g||(d++,h.b==a&&(e=h),!(e&&1<d)));h=h.next)e||(f=h);e&&(0==c.b&&1==d?tm(c,b):(f?(d=f,d.next==c.h&&(c.h=d),d.next=d.next.next):um(c),vm(c,e,3,b)))}a.g=null}else mm(a,3,b)}
function wm(a,b){a.f||2!=a.b&&3!=a.b||xm(a);a.h?a.h.next=b:a.f=b;a.h=b}
function rm(a,b,c,d){var e=pm(null,null,null);e.b=new lm(function(a,h){e.h=b?function(c){try{var e=b.call(d,c);a(e)}catch(n){h(n)}}:a;
e.f=c?function(b){try{var e=c.call(d,b);!p(e)&&b instanceof sm?h(b):a(e)}catch(n){h(n)}}:h});
e.b.g=a;wm(a,e);return e.b}
lm.prototype.C=function(a){this.b=0;mm(this,2,a)};
lm.prototype.V=function(a){this.b=0;mm(this,3,a)};
function mm(a,b,c){if(0==a.b){a==c&&(b=3,c=new TypeError("Promise cannot resolve to itself"));a.b=1;var d;a:{var e=c,f=a.C,h=a.V;if(e instanceof lm)wm(e,pm(f||t,h||null,a)),d=!0;else{var k;if(e)try{k=!!e.$goog_Thenable}catch(n){k=!1}else k=!1;if(k)e.then(f,h,a),d=!0;else{if(ha(e))try{var l=e.then;if(ga(l)){ym(e,l,f,h,a);d=!0;break a}}catch(n){h.call(a,n);d=!0;break a}d=!1}}}d||(a.j=c,a.b=b,a.g=null,xm(a),3!=b||c instanceof sm||zm(a,c))}}
function ym(a,b,c,d,e){function f(a){k||(k=!0,d.call(e,a))}
function h(a){k||(k=!0,c.call(e,a))}
var k=!1;try{b.call(a,h,f)}catch(l){f(l)}}
function xm(a){a.l||(a.l=!0,Rb(a.o,a))}
function um(a){var b=null;a.f&&(b=a.f,a.f=b.next,b.next=null);a.f||(a.h=null);return b}
lm.prototype.o=function(){for(var a=null;a=um(this);)vm(this,a,this.b,this.j);this.l=!1};
function vm(a,b,c,d){if(3==c&&b.f&&!b.g)for(;a&&a.i;a=a.g)a.i=!1;if(b.b)b.b.g=null,Am(b,c,d);else try{b.g?b.h.call(b.context):Am(b,c,d)}catch(e){Bm.call(null,e)}Nb(om,b)}
function Am(a,b,c){2==b?a.h.call(a.context,c):a.f&&a.f.call(a.context,c)}
function zm(a,b){a.i=!0;Rb(function(){a.i&&Bm.call(null,b)})}
var Bm=Jb;function sm(a){pa.call(this,a)}
y(sm,pa);sm.prototype.name="cancel";function Cm(a,b){hm.call(this);this.b=a||1;this.f=b||m;this.h=w(this.pe,this);this.i=x()}
y(Cm,hm);g=Cm.prototype;g.enabled=!1;g.X=null;function Dm(a,b){a.b=b;a.X&&a.enabled?(a.stop(),a.start()):a.X&&a.stop()}
g.pe=function(){if(this.enabled){var a=x()-this.i;0<a&&a<.8*this.b?this.X=this.f.setTimeout(this.h,this.b-a):(this.X&&(this.f.clearTimeout(this.X),this.X=null),im(this,"tick"),this.enabled&&(this.X=this.f.setTimeout(this.h,this.b),this.i=x()))}};
g.start=function(){this.enabled=!0;this.X||(this.X=this.f.setTimeout(this.h,this.b),this.i=x())};
g.stop=function(){this.enabled=!1;this.X&&(this.f.clearTimeout(this.X),this.X=null)};
g.w=function(){Cm.A.w.call(this);this.stop();delete this.f};
function Em(a,b,c){if(ga(a))c&&(a=w(a,c));else if(a&&"function"==typeof a.handleEvent)a=w(a.handleEvent,a);else throw Error("Invalid listener argument");return 2147483647<Number(b)?-1:m.setTimeout(a,b||0)}
;function Fm(a,b,c){E.call(this);this.h=null!=c?w(a,c):a;this.g=b;this.f=w(this.Sd,this);this.b=[]}
y(Fm,E);g=Fm.prototype;g.Oa=!1;g.Ya=0;g.Aa=null;g.gd=function(a){this.b=arguments;this.Aa||this.Ya?this.Oa=!0:Gm(this)};
g.stop=function(){this.Aa&&(m.clearTimeout(this.Aa),this.Aa=null,this.Oa=!1,this.b=[])};
g.pause=function(){this.Ya++};
g.resume=function(){this.Ya--;this.Ya||!this.Oa||this.Aa||(this.Oa=!1,Gm(this))};
g.w=function(){Fm.A.w.call(this);this.stop()};
g.Sd=function(){this.Aa=null;this.Oa&&!this.Ya&&(this.Oa=!1,Gm(this))};
function Gm(a){a.Aa=Em(a.f,a.g);a.h.apply(null,a.b)}
;function Hm(a){E.call(this);this.f=a;this.b={}}
y(Hm,E);var Im=[];Hm.prototype.jb=function(a,b,c,d){da(b)||(b&&(Im[0]=b.toString()),b=Im);for(var e=0;e<b.length;e++){var f=Xl(a,b[e],c||this.handleEvent,d||!1,this.f||this);if(!f)break;this.b[f.key]=f}return this};
Hm.prototype.sb=function(a,b,c,d,e){if(da(b))for(var f=0;f<b.length;f++)this.sb(a,b[f],c,d,e);else c=c||this.handleEvent,e=e||this.f||this,c=Yl(c),d=!!d,b=a&&a[Ll]?Tl(a.g,String(b),c,d,e):a?(a=Zl(a))?Tl(a,b,c,d,e):null:null,b&&(dm(b),delete this.b[b.key]);return this};
function Jm(a){Za(a.b,function(a,c){this.b.hasOwnProperty(c)&&dm(a)},a);
a.b={}}
Hm.prototype.w=function(){Hm.A.w.call(this);Jm(this)};
Hm.prototype.handleEvent=function(){throw Error("EventHandler.handleEvent not implemented");};function Km(){}
Km.prototype.b=null;function Lm(a){var b;(b=a.b)||(b={},Mm(a)&&(b[0]=!0,b[1]=!0),b=a.b=b);return b}
;var Nm;function Om(){}
y(Om,Km);function Pm(a){return(a=Mm(a))?new ActiveXObject(a):new XMLHttpRequest}
function Mm(a){if(!a.f&&"undefined"==typeof XMLHttpRequest&&"undefined"!=typeof ActiveXObject){for(var b=["MSXML2.XMLHTTP.6.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"],c=0;c<b.length;c++){var d=b[c];try{return new ActiveXObject(d),a.f=d}catch(e){}}throw Error("Could not create ActiveXObject. ActiveX might be disabled, or MSXML might not be installed");}return a.f}
Nm=new Om;function Qm(a,b,c,d,e){this.b=a;this.g=c;this.o=d;this.j=e||1;this.i=45E3;this.h=new Hm(this);this.f=new Cm;Dm(this.f,250)}
g=Qm.prototype;g.Ba=null;g.fa=!1;g.Qa=null;g.Vb=null;g.Za=null;g.Pa=null;g.sa=null;g.va=null;g.Fa=null;g.I=null;g.ab=0;g.ga=null;g.vb=null;g.Ca=null;g.Wa=-1;g.Ec=!0;g.xa=!1;g.Mb=0;g.ob=null;var Rm={},Sm={};g=Qm.prototype;g.setTimeout=function(a){this.i=a};
function Tm(a,b,c){a.Pa=1;a.sa=Eg(b.clone());a.Fa=c;a.l=!0;Um(a,null)}
function Vm(a,b,c,d,e){a.Pa=1;a.sa=Eg(b.clone());a.Fa=null;a.l=c;e&&(a.Ec=!1);Um(a,d)}
function Um(a,b){a.Za=x();Wm(a);a.va=a.sa.clone();Cg(a.va,"t",a.j);a.ab=0;a.I=a.b.Fb(a.b.$a()?b:null);0<a.Mb&&(a.ob=new Fm(w(a.Kc,a,a.I),a.Mb));a.h.jb(a.I,"readystatechange",a.be);var c=a.Ba?kb(a.Ba):{};a.Fa?(a.vb="POST",c["Content-Type"]="application/x-www-form-urlencoded",a.I.send(a.va,a.vb,a.Fa,c)):(a.vb="GET",a.Ec&&!cd&&(c.Connection="close"),a.I.send(a.va,a.vb,null,c));a.b.ea(1)}
g.be=function(a){a=a.target;var b=this.ob;b&&3==Xm(a)?b.gd():this.Kc(a)};
g.Kc=function(a){try{if(a==this.I)a:{var b=Xm(this.I),c=this.I.i,d=this.I.getStatus();if(L&&!nd(10)||cd&&!md("420+")){if(4>b)break a}else if(3>b||3==b&&!$c&&!Ym(this.I))break a;this.xa||4!=b||7==c||(8==c||0>=d?this.b.ea(3):this.b.ea(2));Zm(this);var e=this.I.getStatus();this.Wa=e;var f=Ym(this.I);(this.fa=200==e)?(4==b&&$m(this),this.l?(an(this,b,f),$c&&this.fa&&3==b&&(this.h.jb(this.f,"tick",this.ae),this.f.start())):bn(this,f),this.fa&&!this.xa&&(4==b?this.b.lb(this):(this.fa=!1,Wm(this)))):(this.Ca=
400==e&&0<f.indexOf("Unknown SID")?3:0,Y(),$m(this),cn(this))}}catch(h){this.I&&Ym(this.I)}finally{}};
function an(a,b,c){for(var d=!0;!a.xa&&a.ab<c.length;){var e=dn(a,c);if(e==Sm){4==b&&(a.Ca=4,Y(),d=!1);break}else if(e==Rm){a.Ca=4;Y();d=!1;break}else bn(a,e)}4==b&&0==c.length&&(a.Ca=1,Y(),d=!1);a.fa=a.fa&&d;d||($m(a),cn(a))}
g.ae=function(){var a=Xm(this.I),b=Ym(this.I);this.ab<b.length&&(Zm(this),an(this,a,b),this.fa&&4!=a&&Wm(this))};
function dn(a,b){var c=a.ab,d=b.indexOf("\n",c);if(-1==d)return Sm;c=Number(b.substring(c,d));if(isNaN(c))return Rm;d+=1;if(d+c>b.length)return Sm;var e=b.substr(d,c);a.ab=d+c;return e}
function en(a,b){a.Za=x();Wm(a);var c=b?window.location.hostname:"";a.va=a.sa.clone();O(a.va,"DOMAIN",c);O(a.va,"t",a.j);try{a.ga=new ActiveXObject("htmlfile")}catch(n){$m(a);a.Ca=7;Y();cn(a);return}var d="<html><body>";if(b){for(var e="",f=0;f<c.length;f++){var h=c.charAt(f);if("<"==h)e+="\\x3c";else if(">"==h)e+="\\x3e";else{if(h in Ea)h=Ea[h];else if(h in Da)h=Ea[h]=Da[h];else{var k=h,l=h.charCodeAt(0);if(31<l&&127>l)k=h;else{if(256>l){if(k="\\x",16>l||256<l)k+="0"}else k="\\u",4096>l&&(k+="0");
k+=l.toString(16).toUpperCase()}h=Ea[h]=k}e+=h}}d+='<script>document.domain="'+e+'"\x3c/script>'}d+="</body></html>";c=Gc(tb("b/12014412"),d);a.ga.open();a.ga.write(Cb(c));a.ga.close();a.ga.parentWindow.m=w(a.Wd,a);a.ga.parentWindow.d=w(a.zc,a,!0);a.ga.parentWindow.rpcClose=w(a.zc,a,!1);c=a.ga.createElement("DIV");a.ga.parentWindow.document.body.appendChild(c);d=yb(a.va.toString());d=wb(d);za.test(d)&&(-1!=d.indexOf("&")&&(d=d.replace(ta,"&amp;")),-1!=d.indexOf("<")&&(d=d.replace(ua,"&lt;")),-1!=
d.indexOf(">")&&(d=d.replace(va,"&gt;")),-1!=d.indexOf('"')&&(d=d.replace(wa,"&quot;")),-1!=d.indexOf("'")&&(d=d.replace(xa,"&#39;")),-1!=d.indexOf("\x00")&&(d=d.replace(ya,"&#0;")));d=Gc(tb("b/12014412"),'<iframe src="'+d+'"></iframe>');c.innerHTML=Cb(d);a.b.ea(1)}
g.Wd=function(a){fn(w(this.Vd,this,a),0)};
g.Vd=function(a){this.xa||(Zm(this),bn(this,a),Wm(this))};
g.zc=function(a){fn(w(this.Ud,this,a),0)};
g.Ud=function(a){this.xa||($m(this),this.fa=a,this.b.lb(this),this.b.ea(4))};
g.cancel=function(){this.xa=!0;$m(this)};
function Wm(a){a.Vb=x()+a.i;gn(a,a.i)}
function gn(a,b){if(null!=a.Qa)throw Error("WatchDog timer not null");a.Qa=fn(w(a.Yd,a),b)}
function Zm(a){a.Qa&&(m.clearTimeout(a.Qa),a.Qa=null)}
g.Yd=function(){this.Qa=null;var a=x();0<=a-this.Vb?(2!=this.Pa&&this.b.ea(3),$m(this),this.Ca=2,Y(),cn(this)):gn(this,this.Vb-a)};
function cn(a){a.b.lc()||a.xa||a.b.lb(a)}
function $m(a){Zm(a);G(a.ob);a.ob=null;a.f.stop();Jm(a.h);if(a.I){var b=a.I;a.I=null;hn(b);b.dispose()}a.ga&&(a.ga=null)}
function bn(a,b){try{a.b.tc(a,b),a.b.ea(4)}catch(c){}}
;function jn(a,b,c,d,e){if(0==d)c(!1);else{var f=e||0;d--;kn(a,b,function(e){e?c(!0):m.setTimeout(function(){jn(a,b,c,d,f)},f)})}}
function kn(a,b,c){var d=new Image;d.onload=function(){try{ln(d),c(!0)}catch(a){}};
d.onerror=function(){try{ln(d),c(!1)}catch(a){}};
d.onabort=function(){try{ln(d),c(!1)}catch(a){}};
d.ontimeout=function(){try{ln(d),c(!1)}catch(a){}};
m.setTimeout(function(){if(d.ontimeout)d.ontimeout()},b);
d.src=a}
function ln(a){a.onload=null;a.onerror=null;a.onabort=null;a.ontimeout=null}
;function mn(a){this.b=a;this.f=new km(null,!0)}
g=mn.prototype;g.Kb=null;g.U=null;g.pb=!1;g.Hc=null;g.fb=null;g.Pb=null;g.Lb=null;g.Y=null;g.qa=-1;g.Va=null;g.Ra=null;g.connect=function(a){this.Lb=a;a=nn(this.b,null,this.Lb);Y();this.Hc=x();var b=this.b.o;null!=b?(this.Va=b[0],(this.Ra=b[1])?(this.Y=1,on(this)):(this.Y=2,pn(this))):(Cg(a,"MODE","init"),this.U=new Qm(this,0,void 0,void 0,void 0),this.U.Ba=this.Kb,Vm(this.U,a,!1,null,!0),this.Y=0)};
function on(a){var b=nn(a.b,a.Ra,"/mail/images/cleardot.gif");Eg(b);jn(b.toString(),5E3,w(a.cd,a),3,2E3);a.ea(1)}
g.cd=function(a){if(a)this.Y=2,pn(this);else{Y();var b=this.b;b.da=b.ta.qa;qn(b,9)}a&&this.ea(2)};
function pn(a){var b=a.b.C;if(null!=b)Y(),b?(Y(),rn(a.b,a,!1)):(Y(),rn(a.b,a,!0));else if(a.U=new Qm(a,0,void 0,void 0,void 0),a.U.Ba=a.Kb,b=a.b,b=nn(b,b.$a()?a.Va:null,a.Lb),Y(),!L||nd(10))Cg(b,"TYPE","xmlhttp"),Vm(a.U,b,!1,a.Va,!1);else{Cg(b,"TYPE","html");var c=a.U;a=!!a.Va;c.Pa=3;c.sa=Eg(b.clone());en(c,a)}}
g.Fb=function(a){return this.b.Fb(a)};
g.lc=function(){return!1};
g.tc=function(a,b){this.qa=a.Wa;if(0==this.Y)if(b){try{var c=this.f.parse(b)}catch(d){c=this.b;c.da=this.qa;qn(c,2);return}this.Va=c[0];this.Ra=c[1]}else c=this.b,c.da=this.qa,qn(c,2);else if(2==this.Y)if(this.pb)Y(),this.Pb=x();else if("11111"==b){if(Y(),this.pb=!0,this.fb=x(),c=this.fb-this.Hc,!L||nd(10)||500>c)this.qa=200,this.U.cancel(),Y(),rn(this.b,this,!0)}else Y(),this.fb=this.Pb=x(),this.pb=!1};
g.lb=function(){this.qa=this.U.Wa;if(this.U.fa)0==this.Y?this.Ra?(this.Y=1,on(this)):(this.Y=2,pn(this)):2==this.Y&&(a=!1,(a=!L||nd(10)?this.pb:200>this.Pb-this.fb?!1:!0)?(Y(),rn(this.b,this,!0)):(Y(),rn(this.b,this,!1)));else{0==this.Y?Y():2==this.Y&&Y();var a=this.b;a.da=this.qa;qn(a,2)}};
g.$a=function(){return this.b.$a()};
g.isActive=function(){return this.b.isActive()};
g.ea=function(a){this.b.ea(a)};function sn(a){hm.call(this);this.headers=new Mc;this.L=a||null;this.f=!1;this.K=this.b=null;this.ja=this.C="";this.i=0;this.l="";this.h=this.aa=this.o=this.W=!1;this.j=0;this.D=null;this.ka="";this.G=this.la=!1}
y(sn,hm);var tn=/^https?$/i,un=["POST","PUT"];g=sn.prototype;
g.send=function(a,b,c,d){if(this.b)throw Error("[goog.net.XhrIo] Object is active with another request="+this.C+"; newUri="+a);b=b?b.toUpperCase():"GET";this.C=a;this.l="";this.i=0;this.ja=b;this.W=!1;this.f=!0;this.b=this.L?Pm(this.L):Pm(Nm);this.K=this.L?Lm(this.L):Lm(Nm);this.b.onreadystatechange=w(this.sc,this);try{El(vn(this,"Opening Xhr")),this.aa=!0,this.b.open(b,String(a),!0),this.aa=!1}catch(f){El(vn(this,"Error opening Xhr: "+f.message));wn(this,f);return}a=c||"";var e=this.headers.clone();
d&&Tc(d,function(a,b){e.set(b,a)});
d=Na(e.ia(),xn);c=m.FormData&&a instanceof m.FormData;!Pa(un,b)||d||c||e.set("Content-Type","application/x-www-form-urlencoded;charset=utf-8");e.forEach(function(a,b){this.b.setRequestHeader(b,a)},this);
this.ka&&(this.b.responseType=this.ka);fb(this.b)&&(this.b.withCredentials=this.la);try{yn(this),0<this.j&&(this.G=zn(this.b),El(vn(this,"Will abort after "+this.j+"ms if incomplete, xhr2 "+this.G)),this.G?(this.b.timeout=this.j,this.b.ontimeout=w(this.kc,this)):this.D=Em(this.kc,this.j,this)),El(vn(this,"Sending request")),this.o=!0,this.b.send(a),this.o=!1}catch(f){El(vn(this,"Send error: "+f.message)),wn(this,f)}};
function zn(a){return L&&md(9)&&fa(a.timeout)&&p(a.ontimeout)}
function xn(a){return"content-type"==a.toLowerCase()}
g.kc=function(){"undefined"!=typeof aa&&this.b&&(this.l="Timed out after "+this.j+"ms, aborting",this.i=8,vn(this,this.l),im(this,"timeout"),hn(this,8))};
function wn(a,b){a.f=!1;a.b&&(a.h=!0,a.b.abort(),a.h=!1);a.l=b;a.i=5;An(a);Bn(a)}
function An(a){a.W||(a.W=!0,im(a,"complete"),im(a,"error"))}
function hn(a,b){a.b&&a.f&&(vn(a,"Aborting"),a.f=!1,a.h=!0,a.b.abort(),a.h=!1,a.i=b||7,im(a,"complete"),im(a,"abort"),Bn(a))}
g.w=function(){this.b&&(this.f&&(this.f=!1,this.h=!0,this.b.abort(),this.h=!1),Bn(this,!0));sn.A.w.call(this)};
g.sc=function(){this.isDisposed()||(this.aa||this.o||this.h?Cn(this):this.Kd())};
g.Kd=function(){Cn(this)};
function Cn(a){if(a.f&&"undefined"!=typeof aa)if(a.K[1]&&4==Xm(a)&&2==a.getStatus())vn(a,"Local request error detected and ignored");else if(a.o&&4==Xm(a))Em(a.sc,0,a);else if(im(a,"readystatechange"),4==Xm(a)){vn(a,"Request complete");a.f=!1;try{var b=a.getStatus(),c;a:switch(b){case 200:case 201:case 202:case 204:case 206:case 304:case 1223:c=!0;break a;default:c=!1}var d;if(!(d=c)){var e;if(e=0===b){var f=String(a.C).match(yd)[1]||null;if(!f&&m.self&&m.self.location)var h=m.self.location.protocol,
f=h.substr(0,h.length-1);e=!tn.test(f?f.toLowerCase():"")}d=e}if(d)im(a,"complete"),im(a,"success");else{a.i=6;var k;try{k=2<Xm(a)?a.b.statusText:""}catch(l){k=""}a.l=k+" ["+a.getStatus()+"]";An(a)}}finally{Bn(a)}}}
function Bn(a,b){if(a.b){yn(a);var c=a.b,d=a.K[0]?t:null;a.b=null;a.K=null;b||im(a,"ready");try{c.onreadystatechange=d}catch(e){}}}
function yn(a){a.b&&a.G&&(a.b.ontimeout=null);fa(a.D)&&(m.clearTimeout(a.D),a.D=null)}
g.isActive=function(){return!!this.b};
function Xm(a){return a.b?a.b.readyState:0}
g.getStatus=function(){try{return 2<Xm(this)?this.b.status:-1}catch(a){return-1}};
function Ym(a){try{return a.b?a.b.responseText:""}catch(b){return""}}
function vn(a,b){return b+" ["+a.ja+" "+a.C+" "+a.getStatus()+"]"}
;function Dn(a,b,c){this.j=a||null;this.b=1;this.f=[];this.h=[];this.i=new km(null,!0);this.o=b||null;this.C=null!=c?c:null}
function En(a,b){this.b=a;this.map=b;this.context=null}
g=Dn.prototype;g.Ta=null;g.R=null;g.F=null;g.Jb=null;g.gb=null;g.bc=null;g.hb=null;g.Xa=0;g.vd=0;g.M=null;g.ua=null;g.oa=null;g.za=null;g.ta=null;g.ub=null;g.Ka=-1;g.mc=-1;g.da=-1;g.Ua=0;g.Ja=0;g.ya=8;var Fn=new hm;function Gn(a){Hl.call(this,"statevent",a)}
y(Gn,Hl);function Hn(a,b){Hl.call(this,"timingevent",a);this.size=b}
y(Hn,Hl);function In(a){Hl.call(this,"serverreachability",a)}
y(In,Hl);g=Dn.prototype;g.connect=function(a,b,c,d,e){Y();this.Jb=b;this.Ta=c||{};d&&p(e)&&(this.Ta.OSID=d,this.Ta.OAID=e);this.ta=new mn(this);this.ta.Kb=null;this.ta.f=this.i;this.ta.connect(a)};
function Jn(a){Kn(a);if(3==a.b){var b=a.Xa++,c=a.gb.clone();O(c,"SID",a.g);O(c,"RID",b);O(c,"TYPE","terminate");Ln(a,c);b=new Qm(a,0,a.g,b,void 0);b.Pa=2;b.sa=Eg(c.clone());(new Image).src=b.sa;b.Za=x();Wm(b)}Mn(a)}
function Kn(a){if(a.ta){var b=a.ta;b.U&&(b.U.cancel(),b.U=null);b.qa=-1;a.ta=null}a.F&&(a.F.cancel(),a.F=null);a.oa&&(m.clearTimeout(a.oa),a.oa=null);Nn(a);a.R&&(a.R.cancel(),a.R=null);a.ua&&(m.clearTimeout(a.ua),a.ua=null)}
function On(a,b){if(0==a.b)throw Error("Invalid operation: sending map when state is closed");a.f.push(new En(a.vd++,b));2!=a.b&&3!=a.b||Pn(a)}
g.lc=function(){return 0==this.b};
function Pn(a){a.R||a.ua||(a.ua=fn(w(a.yc,a),0),a.Ua=0)}
g.yc=function(a){this.ua=null;Qn(this,a)};
function Qn(a,b){if(1==a.b){if(!b){a.Xa=Math.floor(1E5*Math.random());var c=a.Xa++,d=new Qm(a,0,"",c,void 0);d.Ba=null;var e=Rn(a),f=a.gb.clone();O(f,"RID",c);a.j&&O(f,"CVER",a.j);Ln(a,f);Tm(d,f,e);a.R=d;a.b=2}}else 3==a.b&&(b?Sn(a,b):0!=a.f.length&&(a.R||Sn(a)))}
function Sn(a,b){var c,d;b?6<a.ya?(a.f=a.h.concat(a.f),a.h.length=0,c=a.Xa-1,d=Rn(a)):(c=b.o,d=b.Fa):(c=a.Xa++,d=Rn(a));var e=a.gb.clone();O(e,"SID",a.g);O(e,"RID",c);O(e,"AID",a.Ka);Ln(a,e);c=new Qm(a,0,a.g,c,a.Ua+1);c.Ba=null;c.setTimeout(Math.round(1E4)+Math.round(1E4*Math.random()));a.R=c;Tm(c,e,d)}
function Ln(a,b){if(a.M){var c=a.M.ic(a);c&&Za(c,function(a,c){O(b,c,a)})}}
function Rn(a){var b=Math.min(a.f.length,1E3),c=["count="+b],d;6<a.ya&&0<b?(d=a.f[0].b,c.push("ofs="+d)):d=0;for(var e=0;e<b;e++){var f=a.f[e].b,h=a.f[e].map,f=6>=a.ya?e:f-d;try{Tc(h,function(a,b){c.push("req"+f+"_"+b+"="+encodeURIComponent(a))})}catch(k){c.push("req"+f+"_type="+encodeURIComponent("_badmap"))}}a.h=a.h.concat(a.f.splice(0,b));
return c.join("&")}
function Tn(a){a.F||a.oa||(a.l=1,a.oa=fn(w(a.xc,a),0),a.Ja=0)}
function Un(a){if(a.F||a.oa||3<=a.Ja)return!1;a.l++;a.oa=fn(w(a.xc,a),Vn(a,a.Ja));a.Ja++;return!0}
g.xc=function(){this.oa=null;this.F=new Qm(this,0,this.g,"rpc",this.l);this.F.Ba=null;this.F.Mb=0;var a=this.bc.clone();O(a,"RID","rpc");O(a,"SID",this.g);O(a,"CI",this.ub?"0":"1");O(a,"AID",this.Ka);Ln(this,a);if(!L||nd(10))O(a,"TYPE","xmlhttp"),Vm(this.F,a,!0,this.hb,!1);else{O(a,"TYPE","html");var b=this.F,c=!!this.hb;b.Pa=3;b.sa=Eg(a.clone());en(b,c)}};
function rn(a,b,c){a.ub=c;a.da=b.qa;a.fd(1,0);a.gb=nn(a,null,a.Jb);Pn(a)}
g.tc=function(a,b){if(0!=this.b&&(this.F==a||this.R==a))if(this.da=a.Wa,this.R==a&&3==this.b)if(7<this.ya){var c;try{c=this.i.parse(b)}catch(f){c=null}if(da(c)&&3==c.length)if(0==c[0])a:{if(!this.oa){if(this.F)if(this.F.Za+3E3<this.R.Za)Nn(this),this.F.cancel(),this.F=null;else break a;Un(this);Y()}}else this.mc=c[1],0<this.mc-this.Ka&&37500>c[2]&&this.ub&&0==this.Ja&&!this.za&&(this.za=fn(w(this.wd,this),6E3));else qn(this,11)}else"y2f%"!=b&&qn(this,11);else if(this.F==a&&Nn(this),!/^[\s\xa0]*$/.test(b)){c=
this.i.parse(b);da(c);for(var d=0;d<c.length;d++){var e=c[d];this.Ka=e[0];e=e[1];2==this.b?"c"==e[0]?(this.g=e[1],this.hb=e[2],e=e[3],null!=e?this.ya=e:this.ya=6,this.b=3,this.M&&this.M.gc(this),this.bc=nn(this,this.$a()?this.hb:null,this.Jb),Tn(this)):"stop"==e[0]&&qn(this,7):3==this.b&&("stop"==e[0]?qn(this,7):"noop"!=e[0]&&this.M&&this.M.fc(this,e),this.Ja=0)}}};
g.wd=function(){null!=this.za&&(this.za=null,this.F.cancel(),this.F=null,Un(this),Y())};
function Nn(a){null!=a.za&&(m.clearTimeout(a.za),a.za=null)}
g.lb=function(a){var b;if(this.F==a)Nn(this),this.F=null,b=2;else if(this.R==a)this.R=null,b=1;else return;this.da=a.Wa;if(0!=this.b)if(a.fa)1==b?(x(),im(Fn,new Hn(Fn,a.Fa?a.Fa.length:0)),Pn(this),this.h.length=0):Tn(this);else{var c=a.Ca,d;if(!(d=3==c||7==c||0==c&&0<this.da)){if(d=1==b)this.R||this.ua||1==this.b||2<=this.Ua?d=!1:(this.ua=fn(w(this.yc,this,a),Vn(this,this.Ua)),this.Ua++,d=!0);d=!(d||2==b&&Un(this))}if(d)switch(c){case 1:qn(this,5);break;case 4:qn(this,10);break;case 3:qn(this,6);
break;case 7:qn(this,12);break;default:qn(this,2)}}};
function Vn(a,b){var c=5E3+Math.floor(1E4*Math.random());a.isActive()||(c*=2);return c*b}
g.fd=function(a){if(!Pa(arguments,this.b))throw Error("Unexpected channel state: "+this.b);};
function qn(a,b){if(2==b||9==b){var c=null;a.M&&(c=null);var d=w(a.oe,a);c||(c=new og("//www.google.com/images/cleardot.gif"),Eg(c));kn(c.toString(),1E4,d)}else Y();Wn(a,b)}
g.oe=function(a){a?Y():(Y(),Wn(this,8))};
function Wn(a,b){a.b=0;a.M&&a.M.ec(a,b);Mn(a);Kn(a)}
function Mn(a){a.b=0;a.da=-1;if(a.M)if(0==a.h.length&&0==a.f.length)a.M.Db(a);else{var b=Ua(a.h),c=Ua(a.f);a.h.length=0;a.f.length=0;a.M.Db(a,b,c)}}
function nn(a,b,c){var d=Fg(c);if(""!=d.f)b&&qg(d,b+"."+d.f),rg(d,d.j);else var e=window.location,d=Gg(e.protocol,b?b+"."+e.hostname:e.hostname,e.port,c);a.Ta&&Za(a.Ta,function(a,b){O(d,b,a)});
O(d,"VER",a.ya);Ln(a,d);return d}
g.Fb=function(a){if(a)throw Error("Can't create secondary domain capable XhrIo object.");a=new sn;a.la=!1;return a};
g.isActive=function(){return!!this.M&&this.M.isActive(this)};
function fn(a,b){if(!ga(a))throw Error("Fn must not be null and must be a function");return m.setTimeout(function(){a()},b)}
g.ea=function(){im(Fn,new In(Fn))};
function Y(){im(Fn,new Gn(Fn))}
g.$a=function(){return!(!L||nd(10))};
function Xn(){}
g=Xn.prototype;g.gc=function(){};
g.fc=function(){};
g.ec=function(){};
g.Db=function(){};
g.ic=function(){return{}};
g.isActive=function(){return!0};function Yn(a,b){Cm.call(this);this.l=0;if(ga(a))b&&(a=w(a,b));else if(a&&ga(a.handleEvent))a=w(a.handleEvent,a);else throw Error("Invalid listener argument");this.o=a;Xl(this,"tick",w(this.j,this));Zn(this)}
y(Yn,Cm);Yn.prototype.j=function(){if(500<this.b){var a=this.b;24E4>2*a&&(a*=2);Dm(this,a)}this.o()};
Yn.prototype.start=function(){Yn.A.start.call(this);this.l=x()+this.b};
Yn.prototype.stop=function(){this.l=0;Yn.A.stop.call(this)};
function Zn(a){a.stop();Dm(a,5E3+2E4*Math.random())}
;function $n(a,b){this.D=a;this.l=b;this.g=new H;this.f=new Yn(this.ue,this);this.b=null;this.V=!1;this.i=null;this.C="";this.o=this.h=0;this.j=[]}
y($n,Xn);g=$n.prototype;g.subscribe=function(a,b,c){return this.g.subscribe(a,b,c)};
g.unsubscribe=function(a,b,c){return this.g.unsubscribe(a,b,c)};
g.ha=function(a){return this.g.ha(a)};
g.u=function(a,b){return this.g.u.apply(this.g,arguments)};
g.dispose=function(){this.V||(this.V=!0,this.g.clear(),ao(this),G(this.g))};
g.isDisposed=function(){return this.V};
function bo(a){return{firstTestResults:[""],secondTestResults:!a.b.ub,sessionId:a.b.g,arrayId:a.b.Ka}}
g.connect=function(a,b,c){if(!this.b||2!=this.b.b){this.C="";this.f.stop();this.i=a||null;this.h=b||0;a=this.D+"/test";b=this.D+"/bind";var d=new Dn("1",c?c.firstTestResults:null,c?c.secondTestResults:null),e=this.b;e&&(e.M=null);d.M=this;this.b=d;e?this.b.connect(a,b,this.l,e.g,e.Ka):c?this.b.connect(a,b,this.l,c.sessionId,c.arrayId):this.b.connect(a,b,this.l)}};
function ao(a,b){a.o=b||0;a.f.stop();a.b&&(3==a.b.b&&Qn(a.b),Jn(a.b));a.o=0}
g.sendMessage=function(a,b){var c={_sc:a};b&&nb(c,b);this.f.enabled||2==(this.b?this.b.b:0)?this.j.push(c):co(this)&&On(this.b,c)};
g.gc=function(){Zn(this.f);this.i=null;this.h=0;if(this.j.length){var a=this.j;this.j=[];for(var b=0,c=a.length;b<c;++b)On(this.b,a[b])}this.u("handlerOpened")};
g.ec=function(a,b){var c=2==b&&401==this.b.da;if(4!=b&&!c){if(6==b||410==this.b.da)c=this.f,c.stop(),Dm(c,500);this.f.start()}this.u("handlerError",b)};
g.Db=function(a,b,c){if(!this.f.enabled)this.u("handlerClosed");else if(c)for(a=0,b=c.length;a<b;++a){var d=c[a].map;d&&this.j.push(d)}};
g.ic=function(){var a={v:2};this.C&&(a.gsessionid=this.C);0!=this.h&&(a.ui=""+this.h);0!=this.o&&(a.ui=""+this.o);this.i&&nb(a,this.i);return a};
g.fc=function(a,b){"S"==b[0]?this.C=b[1]:"gracefulReconnect"==b[0]?(Zn(this.f),this.f.start(),Jn(this.b)):this.u("handlerMessage",new Fl(b[0],b[1]))};
function co(a){return!!a.b&&3==a.b.b}
function eo(a,b){(a.l.loungeIdToken=b)||a.f.stop()}
g.ue=function(){this.f.stop();var a=this.b,b=0;a.F&&b++;a.R&&b++;0!=b?this.f.start():this.connect(this.i,this.h)};function fo(a){this.index=-1;this.videoId=this.f="";this.volume=this.b=-1;this.l=!1;this.audioTrackId=null;this.i=this.g=0;this.h=null;this.reset(a)}
function go(a){a.audioTrackId=null;a.h=null;a.b=-1;a.g=0;a.i=x()}
fo.prototype.reset=function(a){this.f="";this.index=-1;this.videoId="";go(this);this.volume=-1;this.l=!1;a&&(this.index=a.index,this.f=a.listId,this.videoId=a.videoId,this.b=a.playerState,this.volume=a.volume,this.l=a.muted,this.audioTrackId=a.audioTrackId,this.h=a.trackData,this.g=a.playerTime,this.i=a.playerTimeAt)};
function ho(a){switch(a.b){case 1:return(x()-a.i)/1E3+a.g;case -1E3:return 0}return a.g}
function io(a){var b={};b.index=a.index;b.listId=a.f;b.videoId=a.videoId;b.playerState=a.b;b.volume=a.volume;b.muted=a.l;b.audioTrackId=a.audioTrackId;b.trackData=lb(a.h);b.playerTime=a.g;b.playerTimeAt=a.i;return b}
fo.prototype.clone=function(){return new fo(io(this))};function Z(a,b,c){V.call(this);this.h=NaN;this.K=!1;this.C=this.o=this.D=this.G=NaN;this.L=[];this.g=this.B=this.b=null;this.ra=a;this.L.push(N(window,"beforeunload",w(this.md,this)));this.f=[];this.B=new fo;this.aa=b.id;this.b=jo(this,c);this.b.subscribe("handlerOpened",this.Ad,this);this.b.subscribe("handlerClosed",this.xd,this);this.b.subscribe("handlerError",this.yd,this);this.b.subscribe("handlerMessage",this.zd,this);eo(this.b,b.token);this.subscribe("remoteQueueChange",function(){var a=this.B.videoId;
tk()&&U("yt-remote-session-video-id",a)},this)}
y(Z,V);g=Z.prototype;g.connect=function(a,b){if(b){var c=b.listId,d=b.videoId,e=b.index,f=b.currentTime||0;5>=f&&(f=0);var h={videoId:d,currentTime:f};c&&(h.listId=c);p(e)&&(h.currentIndex=e);c&&(this.B.f=c);this.B.videoId=d;this.B.index=e||0;this.B.state=3;c=this.B;c.g=f;c.i=x();ko("Connecting with setPlaylist and params: "+M(h));this.b.connect({method:"setPlaylist",params:M(h)},a,xk())}else ko("Connecting without params"),this.b.connect({},a,xk());lo(this)};
g.dispose=function(){this.isDisposed()||(this.u("beforeDispose"),mo(this,3));Z.A.dispose.call(this)};
g.w=function(){no(this);oo(this);po(this);K(this.o);this.o=NaN;K(this.C);this.C=NaN;this.g=null;Oe(this.L);this.L.length=0;this.b.dispose();Z.A.w.call(this);this.f=this.B=this.b=null};
function ko(a){Pj("conn",a)}
g.md=function(){this.i(2)};
function jo(a,b){return new $n(bk(a.ra,"/bc",void 0,!1),b)}
function mo(a,b){a.u("proxyStateChange",b)}
function lo(a){a.h=J(w(function(){ko("Connecting timeout");this.i(1)},a),2E4)}
function no(a){K(a.h);a.h=NaN}
function po(a){K(a.G);a.G=NaN}
function qo(a){oo(a);a.D=J(w(function(){ro(this,"getNowPlaying")},a),2E4)}
function oo(a){K(a.D);a.D=NaN}
g.Ad=function(){ko("Channel opened");this.K&&(this.K=!1,po(this),this.G=J(w(function(){ko("Timing out waiting for a screen.");this.i(1)},this),15E3));
Bk(bo(this.b),this.aa)};
g.xd=function(){ko("Channel closed");isNaN(this.h)?Ck(!0):Ck();this.dispose()};
g.yd=function(a){Ck();isNaN(this.j())?(ko("Channel error: "+a+" without reconnection"),this.dispose()):(this.K=!0,ko("Channel error: "+a+" with reconnection in "+this.j()+" ms"),mo(this,2))};
function so(a,b){b&&(no(a),po(a));b==(co(a.b)&&isNaN(a.h))?b&&(mo(a,1),ro(a,"getSubtitlesTrack")):b?(a.W()&&a.B.reset(),mo(a,1),ro(a,"getNowPlaying"),to(a)):a.i(1)}
function uo(a,b){var c=b.params.videoId;delete b.params.videoId;c==a.B.videoId&&(ib(b.params)?a.B.h=null:a.B.h=b.params,a.u("remotePlayerChange"))}
function vo(a,b){var c=b.params.videoId||b.params.video_id,d=parseInt(b.params.currentIndex,10);a.B.f=b.params.listId||a.B.f;var e=a.B,f=e.videoId;e.videoId=c;e.index=d;c!=f&&go(e);a.u("remoteQueueChange")}
function wo(a,b){b.params=b.params||{};vo(a,b);xo(a,b)}
function xo(a,b){var c=parseInt(b.params.currentTime||b.params.current_time,10),d=a.B;d.g=isNaN(c)?0:c;d.i=x();c=parseInt(b.params.state,10);c=isNaN(c)?-1:c;-1==c&&-1E3==a.B.b&&(c=-1E3);a.B.b=c;1==a.B.b?qo(a):oo(a);a.u("remotePlayerChange")}
function yo(a,b){var c="true"==b.params.muted;a.B.volume=parseInt(b.params.volume,10);a.B.l=c;a.u("remotePlayerChange")}
g.zd=function(a){a.params?ko("Received: action="+a.action+", params="+M(a.params)):ko("Received: action="+a.action+" {}");switch(a.action){case "loungeStatus":a=qd(a.params.devices);this.f=Ka(a,function(a){return new ok(a)});
a=!!Na(this.f,function(a){return"LOUNGE_SCREEN"==a.type});
so(this,a);break;case "loungeScreenConnected":so(this,!0);break;case "loungeScreenDisconnected":Sa(this.f,function(a){return"LOUNGE_SCREEN"==a.type});
so(this,!1);break;case "remoteConnected":var b=new ok(qd(a.params.device));Na(this.f,function(a){return a.equals(b)})||Qa(this.f,b);
break;case "remoteDisconnected":b=new ok(qd(a.params.device));Sa(this.f,function(a){return a.equals(b)});
break;case "gracefulDisconnect":break;case "playlistModified":vo(this,a);break;case "nowPlaying":wo(this,a);break;case "onStateChange":xo(this,a);break;case "onVolumeChanged":yo(this,a);break;case "onSubtitlesTrackChanged":uo(this,a);break;default:ko("Unrecognized action: "+a.action)}};
g.ee=function(){if(this.g){var a=this.g;this.g=null;this.B.videoId!=a&&ro(this,"getNowPlaying")}};
Z.prototype.subscribe=Z.prototype.subscribe;Z.prototype.unsubscribeByKey=Z.prototype.ha;Z.prototype.ja=function(){var a=3;this.isDisposed()||(a=0,isNaN(this.j())?co(this.b)&&isNaN(this.h)&&(a=1):a=2);return a};
Z.prototype.getProxyState=Z.prototype.ja;Z.prototype.i=function(a){ko("Disconnecting with "+a);no(this);this.u("beforeDisconnect",a);1==a&&Ck();ao(this.b,a);this.dispose()};
Z.prototype.disconnect=Z.prototype.i;Z.prototype.ca=function(){var a=this.B;if(this.g){var b=a=this.B.clone(),c=this.g,d=a.index,e=b.videoId;b.videoId=c;b.index=d;c!=e&&go(b)}return io(a)};
Z.prototype.getPlayerContextData=Z.prototype.ca;Z.prototype.la=function(a){var b=new fo(a);b.videoId&&b.videoId!=this.B.videoId&&(this.g=b.videoId,K(this.o),this.o=J(w(this.ee,this),5E3));var c=[];this.B.f==b.f&&this.B.videoId==b.videoId&&this.B.index==b.index||c.push("remoteQueueChange");this.B.b==b.b&&this.B.volume==b.volume&&this.B.l==b.l&&ho(this.B)==ho(b)&&M(this.B.h)==M(b.h)||c.push("remotePlayerChange");this.B.reset(a);A(c,function(a){this.u(a)},this)};
Z.prototype.setPlayerContextData=Z.prototype.la;Z.prototype.W=function(){var a=this.b.l.id,b=Na(this.f,function(b){return"REMOTE_CONTROL"==b.type&&b.id!=a});
return b?b.id:""};
Z.prototype.getOtherConnectedRemoteId=Z.prototype.W;Z.prototype.j=function(){var a=this.b;return a.f.enabled?a.f.l-x():NaN};
Z.prototype.getReconnectTimeout=Z.prototype.j;Z.prototype.Ha=function(){if(!isNaN(this.j())){var a=this.b.f;a.enabled&&(a.stop(),a.start(),a.j())}};
Z.prototype.reconnect=Z.prototype.Ha;function to(a){K(a.C);a.C=J(w(a.i,a,1),864E5)}
function ro(a,b,c){c?ko("Sending: action="+b+", params="+M(c)):ko("Sending: action="+b);a.b.sendMessage(b,c)}
Z.prototype.ka=function(a,b){ro(this,a,b);to(this)};
Z.prototype.sendMessage=Z.prototype.ka;function zo(a){ik.call(this,"ScreenServiceProxy");this.P=a;this.b=[];this.b.push(this.P.$_s("screenChange",w(this.ye,this)));this.b.push(this.P.$_s("onlineScreenChange",w(this.Gd,this)))}
y(zo,ik);g=zo.prototype;g.S=function(a){return this.P.$_gs(a)};
g.contains=function(a){return!!this.P.$_c(a)};
g.get=function(a){return this.P.$_g(a)};
g.start=function(){this.P.$_st()};
g.wb=function(a,b,c){this.P.$_a(a,b,c)};
g.remove=function(a,b,c){this.P.$_r(a,b,c)};
g.tb=function(a,b,c,d){this.P.$_un(a,b,c,d)};
g.w=function(){for(var a=0,b=this.b.length;a<b;++a)this.P.$_ubk(this.b[a]);this.b.length=0;this.P=null;zo.A.w.call(this)};
g.ye=function(){this.u("screenChange")};
g.Gd=function(){this.u("onlineScreenChange")};
W.prototype.$_st=W.prototype.start;W.prototype.$_gspc=W.prototype.ze;W.prototype.$_gsppc=W.prototype.Mc;W.prototype.$_c=W.prototype.contains;W.prototype.$_g=W.prototype.get;W.prototype.$_a=W.prototype.wb;W.prototype.$_un=W.prototype.tb;W.prototype.$_r=W.prototype.remove;W.prototype.$_gs=W.prototype.S;W.prototype.$_gos=W.prototype.Lc;W.prototype.$_s=W.prototype.subscribe;W.prototype.$_ubk=W.prototype.ha;function Ao(){var a={device:"Desktop",app:"youtube-desktop"};lj&&kj();qk();Bo||(Bo=new ak,Dk()&&(Bo.b="/api/loungedev"));Co||(Co=r("yt.mdx.remote.deferredProxies_")||[],q("yt.mdx.remote.deferredProxies_",Co,void 0));Do();var b=Eo();if(!b){var c=new W(Bo);q("yt.mdx.remote.screenService_",c,void 0);b=Eo();kl(c,function(a){a?Fo()&&Dl(Fo(),"YouTube TV"):c.subscribe("onlineScreenChange",function(){qc("yt-remote-receiver-availability-change")})},!(!a||!a.loadCastApiSetupScript))}if(a&&!r("yt.mdx.remote.initialized_")){q("yt.mdx.remote.initialized_",
!0,void 0);
Go("Initializing: "+M(a));Ho.push(nc("yt-remote-cast2-availability-change",function(){qc("yt-remote-receiver-availability-change")}));
Ho.push(nc("yt-remote-cast2-receiver-selected",function(){Io(null);qc("yt-remote-auto-connect","cast-selector-receiver")}));
Ho.push(nc("yt-remote-cast2-session-change",Jo));Ho.push(nc("yt-remote-connection-change",function(a){a?Dl(Fo(),"YouTube TV"):Ko()||(Dl(null,null),zl())}));
var d=Lo();a.isAuto&&(d.id+="#dial");d.name=a.device;d.app=a.app;Go(" -- with channel params: "+M(d));Mo(d);b.start();Fo()||No()}}
function Oo(){pc(Ho);Ho.length=0;G(Po);Po=null;Co&&(A(Co,function(a){a(null)}),Co.length=0,Co=null,q("yt.mdx.remote.deferredProxies_",null,void 0));
Bo=null}
function Qo(){if(xl()){var a=[];if(nj("yt-remote-cast-available")||r("yt.mdx.remote.cloudview.castButtonShown_")||Ro())a.push({key:"cast-selector-receiver",name:So()}),q("yt.mdx.remote.cloudview.castButtonShown_",!0,void 0);return a}return r("yt.mdx.remote.cloudview.initializing_")?[]:To()}
function To(){var a;a=Eo().P.$_gos();var b=Uo();b&&Ro()&&(gk(a,b)||a.push(b));return fk(a)}
function Vo(){if(xl()){var a=yl();return a?{key:"cast-selector-receiver",name:a}:null}return Wo()}
function Wo(){var a=To(),b=Uo();b||(b=Ko());return Na(a,function(a){return b&&Tj(b,a.key)?!0:!1})}
function So(){if(xl())return yl();var a=Uo();return a?a.name:null}
function Uo(){var a=Fo();if(!a)return null;var b=Eo().S();return hk(b,a)}
function Jo(a){Go("remote.onCastSessionChange_: "+Xj(a));if(a){var b=Uo();b&&b.id==a.id?Dl(b.id,"YouTube TV"):(b&&Xo(),Yo(a,1))}else Xo()}
function Zo(a,b){Go("Connecting to: "+M(a));if("cast-selector-receiver"==a.key)Io(b||null),Cl(b||null);else{Xo();Io(b||null);var c=Eo().S();(c=hk(c,a.key))?Yo(c,1):J(function(){$o(null)},0)}}
function Xo(){Bl()?tl().stopSession():ql("stopSession called before API ready.");var a=Ro();a?a.disconnect(1):(rc("yt-remote-before-disconnect",1),rc("yt-remote-connection-change",!1));$o(null)}
function Go(a){Pj("remote",a)}
function Eo(){if(!Po){var a=r("yt.mdx.remote.screenService_");Po=a?new zo(a):null}return Po}
function Fo(){return r("yt.mdx.remote.currentScreenId_")}
function ap(a){q("yt.mdx.remote.currentScreenId_",a,void 0)}
function Io(a){q("yt.mdx.remote.connectData_",a,void 0)}
function Ro(){return r("yt.mdx.remote.connection_")}
function $o(a){var b=Ro();Io(null);a?Ro():ap("");q("yt.mdx.remote.connection_",a,void 0);Co&&(A(Co,function(b){b(a)}),Co.length=0);
b&&!a?rc("yt-remote-connection-change",!1):!b&&a&&qc("yt-remote-connection-change",!0)}
function Ko(){var a=tk();if(!a)return null;var b=Eo().S();return hk(b,a)}
function Yo(a,b){Fo();ap(a.id);var c=new Z(Bo,a,Lo());c.connect(b,r("yt.mdx.remote.connectData_"));c.subscribe("beforeDisconnect",function(a){rc("yt-remote-before-disconnect",a)});
c.subscribe("beforeDispose",function(){Ro()&&(Ro(),$o(null))});
$o(c)}
function No(){var a=Ko();a?(Go("Resume connection to: "+Xj(a)),Yo(a,0)):(Ck(),zl(),Go("Skipping connecting because no session screen found."))}
var Bo=null,Co=null,Po=null;function Do(){var a=Lo();if(ib(a)){var a=sk(),b=nj("yt-remote-session-name")||"",c=nj("yt-remote-session-app")||"",a={device:"REMOTE_CONTROL",id:a,name:b,app:c,"mdx-version":3};q("yt.mdx.remote.channelParams_",a,void 0)}}
function Lo(){return r("yt.mdx.remote.channelParams_")||{}}
function Mo(a){a?(U("yt-remote-session-app",a.app),U("yt-remote-session-name",a.name)):(oj("yt-remote-session-app"),oj("yt-remote-session-name"));q("yt.mdx.remote.channelParams_",a,void 0)}
var Ho=[];var bp=null,cp=[];function dp(){ep();if(Vo()){var a=bp;"html5"!=a.getPlayerType()&&a.loadNewVideoConfig(a.getCurrentVideoConfig(),"html5")}}
function fp(a){"cast-selector-receiver"==a?Al():gp(a)}
function gp(a){var b=Qo();if(a=ek(b,a)){var c=bp;Zo(a,{listId:c.getVideoData().list,videoId:c.getVideoData().video_id,currentTime:c.getCurrentTime()});"html5"!=c.getPlayerType()?c.loadNewVideoConfig(c.getCurrentVideoConfig(),"html5"):c.updateRemoteReceivers&&c.updateRemoteReceivers(b,a)}}
function ep(){var a=bp;a&&a.updateRemoteReceivers&&a.updateRemoteReceivers(Qo(),Vo())}
;var hp=null,ip=[];function jp(a){return{externalChannelId:a.externalChannelId,ud:!!a.isChannelPaid,source:a.source,subscriptionId:a.subscriptionId}}
function kp(a){lp(jp(a))}
function lp(a){yi()?(R(li,new fi(a.externalChannelId,a.ud?{itemType:"U",itemId:a.externalChannelId}:null)),(a="/gen_204?"+Fd({event:"subscribe",source:a.source}))&&Tg(a)):mp(a)}
function mp(a){xi(function(b){b.subscription_ajax&&lp(a)},null)}
function np(a){a=jp(a);R(qi,new hi(a.externalChannelId,a.subscriptionId,null));(a="/gen_204?"+Fd({event:"unsubscribe",source:a.source}))&&Tg(a)}
function op(a){hp&&hp.channelSubscribed(a.b,a.subscriptionId)}
function pp(a){hp&&hp.channelUnsubscribed(a.b)}
;function qp(a){E.call(this);this.f=a;this.f.subscribe("command",this.Cc,this);this.g={};this.h=!1}
y(qp,E);g=qp.prototype;g.start=function(){this.h||this.isDisposed()||(this.h=!0,rp(this.f,"RECEIVING"))};
g.Cc=function(a,b){if(this.h&&!this.isDisposed()){var c=b||{};switch(a){case "addEventListener":if(u(c.event)&&(c=c.event,!(c in this.g))){var d=w(this.ge,this,c);this.g[c]=d;this.addEventListener(c,d)}break;case "removeEventListener":u(c.event)&&sp(this,c.event);break;default:this.b.isReady()&&this.b[a]&&(c=tp(a,b||{}),c=this.b[a].apply(this.b,c),(c=up(a,c))&&this.h&&!this.isDisposed()&&rp(this.f,a,c))}}};
g.ge=function(a,b){this.h&&!this.isDisposed()&&rp(this.f,a,this.Gb(a,b))};
g.Gb=function(a,b){if(null!=b)return{value:b}};
function sp(a,b){b in a.g&&(a.removeEventListener(b,a.g[b]),delete a.g[b])}
g.w=function(){this.f.unsubscribe("command",this.Cc,this);this.f=null;for(var a in this.g)sp(this,a);qp.A.w.call(this)};function vp(a,b){qp.call(this,b);this.b=a;this.start()}
y(vp,qp);vp.prototype.addEventListener=function(a,b){this.b.addEventListener(a,b)};
vp.prototype.removeEventListener=function(a,b){this.b.removeEventListener(a,b)};
function tp(a,b){switch(a){case "loadVideoById":return b=tj(b),vj(b),[b];case "cueVideoById":return b=tj(b),vj(b),[b];case "loadVideoByPlayerVars":return vj(b),[b];case "cueVideoByPlayerVars":return vj(b),[b];case "loadPlaylist":return b=uj(b),vj(b),[b];case "cuePlaylist":return b=uj(b),vj(b),[b];case "seekTo":return[b.seconds,b.allowSeekAhead];case "playVideoAt":return[b.index];case "setVolume":return[b.volume];case "setPlaybackQuality":return[b.suggestedQuality];case "setPlaybackRate":return[b.suggestedRate];
case "setLoop":return[b.loopPlaylists];case "setShuffle":return[b.shufflePlaylist];case "getOptions":return[b.module];case "getOption":return[b.module,b.option];case "setOption":return[b.module,b.option,b.value];case "handleGlobalKeyDown":return[b.keyCode,b.shiftKey]}return[]}
function up(a,b){switch(a){case "isMuted":return{muted:b};case "getVolume":return{volume:b};case "getPlaybackRate":return{playbackRate:b};case "getAvailablePlaybackRates":return{availablePlaybackRates:b};case "getVideoLoadedFraction":return{videoLoadedFraction:b};case "getPlayerState":return{playerState:b};case "getCurrentTime":return{currentTime:b};case "getPlaybackQuality":return{playbackQuality:b};case "getAvailableQualityLevels":return{availableQualityLevels:b};case "getDuration":return{duration:b};
case "getVideoUrl":return{videoUrl:b};case "getVideoEmbedCode":return{videoEmbedCode:b};case "getPlaylist":return{playlist:b};case "getPlaylistIndex":return{playlistIndex:b};case "getOptions":return{options:b};case "getOption":return{option:b}}}
vp.prototype.Gb=function(a,b){switch(a){case "onReady":return;case "onStateChange":return{playerState:b};case "onPlaybackQualityChange":return{playbackQuality:b};case "onPlaybackRateChange":return{playbackRate:b};case "onError":return{errorCode:b}}return vp.A.Gb.call(this,a,b)};
vp.prototype.w=function(){vp.A.w.call(this);delete this.b};function wp(){var a=this.f=new Wi,b=w(this.ce,this);a.f=b;a.g=null;this.h=[];this.l=!1;this.i={}}
g=wp.prototype;g.ce=function(a,b){if("addEventListener"==a&&b){var c=b[0];this.i[c]||"onReady"==c||(this.addEventListener(c,xp(this,c)),this.i[c]=!0)}else this.Pc(a,b)};
g.Pc=function(){};
function xp(a,b){return w(function(a){this.sendMessage(b,a)},a)}
g.addEventListener=function(){};
g.hd=function(){this.l=!0;this.sendMessage("initialDelivery",this.Hb());this.sendMessage("onReady");A(this.h,this.Qc,this);this.h=[]};
g.Hb=function(){return null};
function yp(a,b){a.sendMessage("infoDelivery",b)}
g.Qc=function(a){this.l?this.f.sendMessage(a):this.h.push(a)};
g.sendMessage=function(a,b){this.Qc({event:a,info:void 0==b?null:b})};
g.dispose=function(){this.f=null};function zp(a){wp.call(this);this.b=a;this.g=[];this.addEventListener("onReady",w(this.Ld,this));this.addEventListener("onVideoProgress",w(this.ke,this));this.addEventListener("onVolumeChange",w(this.le,this));this.addEventListener("onApiChange",w(this.fe,this));this.addEventListener("onPlaybackQualityChange",w(this.he,this));this.addEventListener("onPlaybackRateChange",w(this.ie,this));this.addEventListener("onStateChange",w(this.je,this))}
y(zp,wp);g=zp.prototype;g.Pc=function(a,b){if(this.b[a]){b=b||[];if(0<b.length&&rj(a)){var c;c=b;if(ha(c[0])&&!da(c[0]))c=c[0];else{var d={};switch(a){case "loadVideoById":case "cueVideoById":d=tj.apply(window,c);break;case "loadVideoByUrl":case "cueVideoByUrl":d=sj.apply(window,c);break;case "loadPlaylist":case "cuePlaylist":d=uj.apply(window,c)}c=d}vj(c);b.length=1;b[0]=c}this.b[a].apply(this.b,b);rj(a)&&yp(this,this.Hb())}};
g.Ld=function(){var a=w(this.hd,this);this.f.b=a};
g.addEventListener=function(a,b){this.g.push({eventType:a,listener:b});this.b.addEventListener(a,b)};
g.Hb=function(){if(!this.b)return null;var a=this.b.getApiInterface();Ra(a,"getVideoData");for(var b={apiInterface:a},c=0,d=a.length;c<d;c++){var e=a[c],f=e;if(0==f.search("get")||0==f.search("is")){var f=e,h=0;0==f.search("get")?h=3:0==f.search("is")&&(h=2);f=f.charAt(h).toLowerCase()+f.substr(h+1);try{var k=this.b[e]();b[f]=k}catch(l){}}}b.videoData=this.b.getVideoData();return b};
g.je=function(a){a={playerState:a,currentTime:this.b.getCurrentTime(),duration:this.b.getDuration(),videoData:this.b.getVideoData(),videoStartBytes:0,videoBytesTotal:this.b.getVideoBytesTotal(),videoLoadedFraction:this.b.getVideoLoadedFraction(),playbackQuality:this.b.getPlaybackQuality(),availableQualityLevels:this.b.getAvailableQualityLevels(),videoUrl:this.b.getVideoUrl(),playlist:this.b.getPlaylist(),playlistIndex:this.b.getPlaylistIndex()};this.b.getProgressState&&(a.progressState=this.b.getProgressState());
this.b.getStoryboardFormat&&(a.storyboardFormat=this.b.getStoryboardFormat());yp(this,a)};
g.he=function(a){yp(this,{playbackQuality:a})};
g.ie=function(a){yp(this,{playbackRate:a})};
g.fe=function(){for(var a=this.b.getOptions(),b={namespaces:a},c=0,d=a.length;c<d;c++){var e=a[c],f=this.b.getOptions(e);b[e]={options:f};for(var h=0,k=f.length;h<k;h++){var l=f[h],n=this.b.getOption(e,l);b[e][l]=n}}this.sendMessage("apiInfoDelivery",b)};
g.le=function(){yp(this,{muted:this.b.isMuted(),volume:this.b.getVolume()})};
g.ke=function(a){a={currentTime:a,videoBytesLoaded:this.b.getVideoBytesLoaded(),videoLoadedFraction:this.b.getVideoLoadedFraction()};this.b.getProgressState&&(a.progressState=this.b.getProgressState());yp(this,a)};
g.dispose=function(){zp.A.dispose.call(this);for(var a=0;a<this.g.length;a++){var b=this.g[a];this.b.removeEventListener(b.eventType,b.listener)}this.g=[]};function Ap(a,b,c){V.call(this);this.b=a;this.f=b;this.g=c}
y(Ap,V);function rp(a,b,c){if(!a.isDisposed()){var d=a.b,e=a.f;a=a.g;d.isDisposed()||e!=d.b||(b={id:a,command:b},c&&(b.data=c),d.b.postMessage(M(b),d.g))}}
Ap.prototype.w=function(){this.f=this.b=null;Ap.A.w.call(this)};function Bp(a,b,c){E.call(this);this.b=a;this.g=c;this.h=N(window,"message",w(this.i,this));this.f=new Ap(this,a,b);Xb(this,oa(G,this.f))}
y(Bp,E);Bp.prototype.i=function(a){var b;if(b=!this.isDisposed())if(b=a.origin==this.g)a:{b=this.b;do{var c;b:{c=a.source;do{if(c==b){c=!0;break b}if(c==c.parent)break;c=c.parent}while(null!=c);c=!1}if(c){b=!0;break a}b=b.opener}while(null!=b);b=!1}if(b&&(c=a.data,u(c))){try{c=qd(c)}catch(d){return}c.command&&(a=this.f,b=c.command,c=c.data,a.isDisposed()||a.u("command",b,c))}};
Bp.prototype.w=function(){Oe(this.h);this.b=null;Bp.A.w.call(this)};var Cp=!1;function Dp(a){if(a=a.match(/[\d]+/g))a.length=3}
(function(){if(navigator.plugins&&navigator.plugins.length){var a=navigator.plugins["Shockwave Flash"];if(a&&(Cp=!0,a.description)){Dp(a.description);return}if(navigator.plugins["Shockwave Flash 2.0"]){Cp=!0;return}}if(navigator.mimeTypes&&navigator.mimeTypes.length&&(a=navigator.mimeTypes["application/x-shockwave-flash"],Cp=!!a&&a.enabledPlugin)){Dp(a.enabledPlugin.description);return}try{var b=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");Cp=!0;Dp(b.GetVariable("$version"));return}catch(c){}try{b=
new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");Cp=!0;return}catch(c){}try{b=new ActiveXObject("ShockwaveFlash.ShockwaveFlash"),Cp=!0,Dp(b.GetVariable("$version"))}catch(c){}})();function Ep(a){return(a=a.exec(ob))?a[1]:""}
(function(){if(rf)return Ep(/Firefox\/([0-9.]+)/);if(L||ad||$c)return kd;if(vf)return Ep(/Chrome\/([0-9.]+)/);if(wf&&!(Zc()||B("iPad")||B("iPod")))return Ep(/Version\/([0-9.]+)/);if(sf||tf){var a=/Version\/(\S+).*Mobile\/(\S+)/.exec(ob);if(a)return a[1]+"."+a[2]}else if(uf)return(a=Ep(/Android\s+([0-9.]+)/))?a:Ep(/Version\/([0-9.]+)/);return""})();function Fp(){var a={format:"RAW",method:"GET",timeout:5E3,withCredentials:!0};return new lm(function(b,c){a.Z=function(a){Md(a)?b(a):c(a)};
a.onError=c;a.Ea=c;Rd("//googleads.g.doubleclick.net/pagead/id",a)})}
;var Gp=null;function Hp(a){a=a.responseText;if(0!=a.lastIndexOf(")]}'",0))return Ip(""),"";a=JSON.parse(a.substr(4)).id;Ip(a);return a}
function Jp(){J(function(){Gp=null},3E5)}
function Ip(a){q("yt.www.ads.biscotti.lastId_",a,void 0)}
;function Kp(){}
;function Lp(a){for(var b=0;b<a.length;b++){var c=a[b];"send_follow_on_ping_action"==c.name&&c.data&&c.data.follow_on_url&&(c=c.data.follow_on_url)&&Tg(c)}}
;function Mp(a){P.call(this,1,arguments);this.Cb=a}
y(Mp,P);function Np(a,b){P.call(this,2,arguments);this.f=a;this.b=b}
y(Np,P);function Op(a,b,c,d){P.call(this,1,arguments);this.b=b;this.g=c||null;this.f=d||null}
y(Op,P);function Pp(a,b){P.call(this,1,arguments);this.f=a;this.b=b||null}
y(Pp,P);function Qp(a){P.call(this,1,arguments)}
y(Qp,P);var Rp=new Q("ypc-core-load",Mp),Sp=new Q("ypc-guide-sync-success",Np),Tp=new Q("ypc-purchase-success",Op),Up=new Q("ypc-subscription-cancel",Qp),Vp=new Q("ypc-subscription-cancel-success",Pp),Wp=new Q("ypc-init-subscription",Qp);var Xp=!1,Yp=[],Zp=[];function $p(a){a.b?Xp?R(pi,a):R(Rp,new Mp(function(){R(Wp,new Qp(a.b))})):aq(a.f,a.h,a.g,a.source)}
function bq(a){a.b?Xp?R(ui,a):R(Rp,new Mp(function(){R(Up,new Qp(a.b))})):cq(a.f,a.subscriptionId,a.h,a.g,a.source)}
function dq(a){eq(Ua(a.b))}
function fq(a){gq(Ua(a.b))}
function hq(a){iq(a.b,a.isEnabled,null)}
function jq(a,b,c,d){iq(a,b,c,d)}
function kq(a){var b=a.f,c=a.b.subscriptionId;b&&c&&R(oi,new gi(b,c,a.b.channelInfo))}
function lq(a){var b=a.b;Za(a.f,function(a,d){R(oi,new gi(d,a,b[d]))})}
function mq(a){R(ti,new di(a.f.itemId));a.b&&a.b.length&&(nq(a.b,ti),nq(a.b,vi))}
function aq(a,b,c,d){var e=new di(a);R(mi,e);var f={};f.c=a;c&&(f.eurl=c);d&&(f.source=d);c={};(d=I("PLAYBACK_ID"))&&(c.plid=d);(d=I("EVENT_ID"))&&(c.ei=d);b&&oq(b,c);Rd("/subscription_ajax?action_create_subscription_to_channel=1",{method:"POST",Ub:f,J:c,Z:function(b,c){var d=c.response;R(oi,new gi(a,d.id,d.channel_info));d.show_feed_privacy_dialog&&qc("SHOW-FEED-PRIVACY-SUBSCRIBE-DIALOG",a);d.actions&&Lp(d.actions)},
Qb:function(){R(ni,e)}})}
function cq(a,b,c,d,e){var f=new di(a);R(ri,f);var h={};d&&(h.eurl=d);e&&(h.source=e);d={};d.c=a;d.s=b;(a=I("PLAYBACK_ID"))&&(d.plid=a);(a=I("EVENT_ID"))&&(d.ei=a);c&&oq(c,d);Rd("/subscription_ajax?action_remove_subscriptions=1",{method:"POST",Ub:h,J:d,Z:function(a,b){var c=b.response;R(ti,f);c.actions&&Lp(c.actions)},
Qb:function(){R(si,f)}})}
function iq(a,b,c,d){if(null!==b||null!==c){var e={};a&&(e.channel_id=a);null===b||(e.email_on_upload=b);null===c||(e.receive_no_updates=c);Rd("/subscription_ajax?action_update_subscription_preferences=1",{method:"POST",J:e,onError:function(){d&&d()}})}}
function eq(a){if(a.length){var b=Wa(a,0,40);R("subscription-batch-subscribe-loading");nq(b,mi);var c={};c.a=b.join(",");var d=function(){R("subscription-batch-subscribe-loaded");nq(b,ni)};
Rd("/subscription_ajax?action_create_subscription_to_all=1",{method:"POST",J:c,Z:function(c,f){d();var h=f.response,k=h.id;if(da(k)&&k.length==b.length){var l=h.channel_info_map;A(k,function(a,c){var d=b[c];R(oi,new gi(d,a,l[d]))});
a.length?eq(a):R("subscription-batch-subscribe-finished")}},
onError:function(){d();R("subscription-batch-subscribe-failure")}})}}
function gq(a){if(a.length){var b=Wa(a,0,40);R("subscription-batch-unsubscribe-loading");nq(b,ri);var c={};c.c=b.join(",");var d=function(){R("subscription-batch-unsubscribe-loaded");nq(b,si)};
Rd("/subscription_ajax?action_remove_subscriptions=1",{method:"POST",J:c,Z:function(){d();nq(b,ti);a.length&&gq(a)},
onError:function(){d()}})}}
function nq(a,b){A(a,function(a){R(b,new di(a))})}
function oq(a,b){var c=Id(a),d;for(d in c)b[d]=c[d]}
;var pq,qq=null,rq=null,sq=null,tq=!1;
function uq(){var a=I("PLAYER_CONFIG",void 0),b=I("REVERSE_MOBIUS_PERCENT",void 0);if("1"!=a.privembed&&Zf&&100*Math.random()<b||eg("enable_server_side_ad_request_for_embeds"))try{var c;try{var d=r("yt.www.ads.biscotti.getId_"),e;if(d)e=d();else{if(!Gp){var f=Fp().then(Hp),h=pm(Jp,Jp,void 0);h.g=!0;wm(f,h);Gp=f}e=Gp}c=e}catch(k){c=qm(k)}rm(c,null,Kp,void 0)}catch(k){ec(k)}if(I("REQUEST_POST_MESSAGE_ORIGIN")){if(!pq){pq=new Wi;pq.b=uq;return}pq.origin&&"*"!=pq.origin&&(a.args.post_message_origin=pq.origin)}d=
document.referrer;b=I("POST_MESSAGE_ORIGIN");c=!1;eg("legacy_cast")&&u(d)&&u(b)&&-1<d.indexOf(b)&&Og(b)&&Og(d)&&(c=!0);window!=window.top&&d&&d!=document.URL&&(a.args.loaderUrl=d);I("LIGHTWEIGHT_AUTOPLAY")&&(a.args.autoplay="1");a.args.autoplay&&vj(a.args);qq=Rh("player",a);d=I("POST_MESSAGE_ID","player");I("ENABLE_JS_API")?sq=new zp(qq):I("ENABLE_POST_API")&&u(d)&&u(b)&&(rq=new Bp(window.parent,d,b),sq=new vp(qq,rq.f));eg("legacy_cast")&&((tq=c&&!I("ENABLE_CAST_API"))?a.args.disableCast="1":(a=qq,
Ao(),bp=a,bp.addEventListener("onReady",dp),bp.addEventListener("onRemoteReceiverSelected",fp),cp.push(nc("yt-remote-receiver-availability-change",ep)),cp.push(nc("yt-remote-auto-connect",gp))));I("BG_P")&&(I("BG_I")||I("BG_IU"))&&Dc();ae();hp=qq;hp.addEventListener("SUBSCRIBE",kp);hp.addEventListener("UNSUBSCRIBE",np);ip.push(ah(oi,op),ah(ti,pp))}
;q("yt.setConfig",bc,void 0);q("yt.setMsg",function(a){cc(ac,arguments)},void 0);
q("yt.logging.errors.log",function(a,b,c,d,e){c={name:c||"WEB",version:d||I("INNERTUBE_CONTEXT_CLIENT_VERSION",void 0)};e=window&&window.yterr||e;if(a&&e&&!(5<=Xd)){e=a.stacktrace;d=a.columnNumber;var f=r("window.location.href");if(u(a))a={message:a,name:"Unknown error",lineNumber:"Not available",fileName:f,stack:"Not available"};else{var h,k,l=!1;try{h=a.lineNumber||a.Ve||"Not available"}catch(v){h="Not available",l=!0}try{k=a.fileName||a.filename||a.sourceURL||m.$googDebugFname||f}catch(v){k="Not available",
l=!0}a=!l&&a.lineNumber&&a.fileName&&a.stack&&a.message&&a.name?a:{message:a.message||"Not available",name:a.name||"UnknownError",lineNumber:h,fileName:k,stack:a.stack||"Not available"}}e=e||a.stack;h=a.lineNumber.toString();isNaN(h)||isNaN(d)||(h=h+":"+d);if(!(Wd[a.message]||0<=e.indexOf("/YouTubeCenter.js")||0<=e.indexOf("/mytube.js"))){b={Ub:{a:"logerror",t:"jserror",type:a.name,msg:a.message.substr(0,1E3),line:h,level:b||"ERROR"},J:{url:I("PAGE_NAME",window.location.href),file:a.fileName},method:"POST"};
e&&(b.J.stack=e);for(var n in c)b.J["client."+n]=c[n];if(n=I("LATEST_ECATCHER_SERVICE_TRACKING_PARAMS",void 0))for(var D in n)b.J[D]=n[D];Rd("/error_204",b);Wd[a.message]=!0;Xd++}}},void 0);
q("writeEmbed",uq,void 0);q("yt.www.watch.ads.restrictioncookie.spr",function(a){(a+="mac_204?action_fcts=1")&&Tg(a);return!0},void 0);
var vq=dc(function(){ph("ol");Xp=!0;Zp.push(ah(li,$p),ah(qi,bq));Xp||(Zp.push(ah(pi,$p),ah(ui,bq),ah(ii,dq),ah(ji,fq),ah(ki,hq)),Yp.push(nc("subscription-prefs",jq)),Zp.push(ah(Tp,kq),ah(Vp,mq),ah(Sp,lq)));xf.getInstance();var a=1<window.devicePixelRatio;if(Cf(0,119)!=a){var b="f"+(Math.floor(119/31)+1),c=Bf(b)||0,c=a?c|67108864:c&-67108865;0==c?delete yf[b]:(a=c.toString(16),yf[b]=a.toString());var b=[],d;for(d in yf)b.push(d+"="+escape(yf[d]));Xe("PREF",b.join("&"),63072E3)}}),wq=dc(function(){var a=
qq;
a&&a.sendAbandonmentPing&&a.sendAbandonmentPing();I("PL_ATT")&&(Cc=null);for(var a=0,b=Zd.length;a<b;a++){var c=Zd[a];if(!isNaN(c)){var d=r("yt.scheduler.instance.cancelJob");d?d(c):K(c)}}Zd.length=0;a=yc("//static.doubleclick.net/instream/ad_status.js");if(b=document.getElementById(a))tc(a),b.parentNode.removeChild(b);$d=!1;bc("DCLKSTAT",0);pc(Yp);Yp.length=0;bh(Zp);Zp.length=0;Xp=!1;hp&&(hp.removeEventListener("SUBSCRIBE",lp),hp.removeEventListener("UNSUBSCRIBE",np));hp=null;bh(ip);ip.length=0;
eg("legacy_cast")&&!tq&&(pc(cp),cp.length=0,bp&&(bp.removeEventListener("onRemoteReceiverSelected",fp),bp.removeEventListener("onReady",dp),bp=null),Oo());Yb(sq,rq);qq&&qq.destroy()});
window.addEventListener?(window.addEventListener("load",vq),window.addEventListener("unload",wq)):window.attachEvent&&(window.attachEvent("onload",vq),window.attachEvent("onunload",wq));var xq=Qi.getInstance(),yq=T(xq);yq in Vi||(xq.register(),xq.nb.push(nc("yt-uix-init-"+yq,xq.init,xq)),xq.nb.push(nc("yt-uix-dispose-"+yq,xq.dispose,xq)),Vi[yq]=xq);})();
