const canvas=document.getElementById("myCanvas");
canvas.width=200;
const car_width=30, car_height=50, speed=2, initial_pos=120, finish_line=350;
const ctx = canvas.getContext("2d");
const road=new Road(canvas.width/2,canvas.width*0.9, laneCount=4, finishLine=finish_line, initialPos=initial_pos);

const _b1=-200, _b2=-310, _b3=-420, _d=30, _colors=["LightBlue", "LightGreen", "LightSteelBlue", "LightSlateGray", "LightGrey", "LightSlateGrey", "LightYellow", "LightPink", "LightSalmon", "LightSeaGreen", "LightCoral", "LightCyan", "LightSkyBlue", "LightGray", "Indigo  ", "Gold", "MediumSpringGreen", "PaleVioletRed", "Linen", "Black", "Peru", "LemonChiffon", "SaddleBrown", "White", "SkyBlue", "HoneyDew", "Tan", "Brown", "PaleTurquoise", "Silver", "DimGrey", "SlateBlue", "OldLace", "PapayaWhip", "Cornsilk", "Bisque", "OliveDrab", "Purple", "HotPink", "MidnightBlue", "SeaShell", "PaleGoldenRod", "SandyBrown", "Orchid", "CadetBlue", "RosyBrown", "AntiqueWhite", "ForestGreen", "Khaki", "Crimson", "PeachPuff", "Olive", "Ivory", "Red", "GhostWhite", "Maroon", "GreenYellow", "GoldenRod", "Magenta", "Violet", "Navy", "MediumAquaMarine", "SteelBlue", "Moccasin", "AliceBlue", "MediumVioletRed", "LimeGreen", "Aqua", "Turquoise", "OrangeRed", "Beige", "Teal", "Fuchsia", "SpringGreen", "MintCream", "Salmon", "DeepSkyBlue", "WhiteSmoke", "MediumSlateBlue", "Green", "DimGray", "LawnGreen", "Gray", "DodgerBlue", "PowderBlue", "Grey", "SlateGray", "BlanchedAlmond", "LavenderBlush", "MediumBlue", "Tomato", "RebeccaPurple", "Chocolate", "MistyRose", "Orange", "DeepPink", "MediumPurple", "Plum", "BurlyWood", "MediumSeaGreen", "YellowGreen", "CornflowerBlue", "Lime", "MediumTurquoise", "Thistle", "Pink", "FloralWhite", "Snow", "Gainsboro", "FireBrick", "MediumOrchid", "Yellow", "NavajoWhite", "PaleGreen", "Cyan", "Lavender", "IndianRed ", "Sienna", "SlateGrey", "Wheat", "Chartreuse", "Aquamarine", "Blue", "Azure", "Coral", "SeaGreen", "RoyalBlue", "BlueViolet"];

// true para usar o PROLOG e false para usar as TECLAS do teclado
const use_prolog = true;
const car=new Car(road.getLaneCenter(1),initial_pos,30,50,canvas.width,(use_prolog)?"PROLOG":"KEYS",speed+0.5,_colors[0]);

const traffic=[
    car,
    //1º
    new Car(road.getLaneCenter(0),_b1+_d*3,car_width,car_height,canvas.width,"DUMMY",speed,_colors[1]),
    new Car(road.getLaneCenter(1),_b1+_d*2,car_width,car_height,canvas.width,"DUMMY",speed,_colors[2]),
    new Car(road.getLaneCenter(2),_b1+_d*1,car_width,car_height,canvas.width,"DUMMY",speed,_colors[3]),
    new Car(road.getLaneCenter(3),_b1+_d*0,car_width,car_height,canvas.width,"DUMMY",speed,_colors[4]),
    //2º
    new Car(road.getLaneCenter(0),_b2+_d*3,car_width,car_height,canvas.width,"DUMMY",speed,_colors[5]),
    new Car(road.getLaneCenter(1),_b2+_d*2,car_width,car_height,canvas.width,"DUMMY",speed,_colors[6]),
    new Car(road.getLaneCenter(2),_b2+_d*1,car_width,car_height,canvas.width,"DUMMY",speed,_colors[7]),
    new Car(road.getLaneCenter(3),_b2+_d*0,car_width,car_height,canvas.width,"DUMMY",speed,_colors[8]),
    //3º
    new Car(road.getLaneCenter(0),_b3+_d*3,car_width,car_height,canvas.width,"DUMMY",speed,_colors[9]),
    new Car(road.getLaneCenter(1),_b3+_d*2,car_width,car_height,canvas.width,"DUMMY",speed,_colors[10]),
    new Car(road.getLaneCenter(2),_b3+_d*1,car_width,car_height,canvas.width,"DUMMY",speed,_colors[11]),
    new Car(road.getLaneCenter(3),_b3+_d*0,car_width,car_height,canvas.width,"DUMMY",speed,_colors[12])
];

animate();
var last_pos = 0, race_position, race_car_position=10, first_time=0, last_time=0;

function animate(){
    var run_finished = car.y <= (finish_line*-10+initial_pos);
    if (first_time == 0) first_time = (new Date()).getTime();
    
    for(let i=0;i<traffic.length && !run_finished;i++){
        let new_traffic = new Array();
        for(let j=0;j<traffic.length;j++){
            if (i!=j) new_traffic.push(traffic[j]);
        }
        traffic[i].update(road.borders,new_traffic);
    }

    canvas.height=window.innerHeight;

    ctx.save();
    ctx.translate(0,-car.y+canvas.height*0.7); //posiciona a visão da pista
    
    road.draw(ctx);
    for(let i=1;i<traffic.length;i++){
        traffic[i].draw(ctx);
    }
    car.draw(ctx, true /*mostrar os sensores*/);

    ctx.restore();

    requestAnimationFrame(animate);
    if (last_pos != car.y && !run_finished){
        last_pos = -Math.round((Math.round(car.y) - initial_pos)/10);
        race_position = traffic.length;
        for(let i=1;i<traffic.length;i++)
            if (car.y < traffic[i].y)
                race_position--;
        $('#km').html('KM: '+last_pos+' ['+race_position+'º]');
        s = (new Date((new Date()).getTime()-first_time)).getSeconds();
        $('#tempo').text('Tempo: '+s+'s')
    }
    if (run_finished){
        if (last_time == 0){
            last_time = (new Date()).getTime();
            var seconds = (new Date(last_time-first_time)).getSeconds();
            $('#km').text('Posição: '+race_position+'º');
            $('#tempo').text('Tempo: '+seconds+'s');
        }
    }
}
