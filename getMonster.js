var page = require('webpage').create();
var url = 'http://regles-pathfinder.fr/Monstres.html';
var fs = require('fs');
var monsters = [];
var counter = 0;
var waitingTime = 10;

// récupération des liens des monstres
page.open(url, function(status) {
	console.log("get links");
    monsters = page.evaluate(function() {
        return [].map.call(document.querySelectorAll('a.pagelink'), function(link) {
            return link.getAttribute('href');
        });
    });
	console.log("found "+monsters.length+" monsters");
	setTimeout(next_page,waitingTime);
});

//récupération des données des monstres
function handle_page(link){
    page.open(link,function(status){
        if(status === "success"){
			//page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js', function() {
				var element = page.evaluate(function() {
					return document.querySelector(".BD");
				});
				//write monsters
				if(element){
					var value="<!doctype html>\n<html>\n<head>\n<meta charset='UTF-8' />\n<link type='text/css' href='style.css' />\n</head>\n<body>\n";
					value += element.innerHTML;
					value += "</body></html>";
					fs.write("./monsters/"+monsters[counter],value, 'w');
					
				}
			//});		
		}else{
            console.error("\tError opening :"+monsters[counter]);
		}
		
		counter++;
		if(counter< monsters.length){
			setTimeout(next_page,waitingTime);
		}else{
			phantom.exit();
		}
    });
}
function next_page(){
	var monsterLink ="http://regles-pathfinder.fr/"+encodeURIComponent(monsters[counter]);
	console.log(monsterLink);
    handle_page(monsterLink);
}
