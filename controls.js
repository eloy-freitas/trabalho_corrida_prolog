class Controls{
    constructor(type){
        this.forward=false;
        this.left=false;
        this.right=false;
        this.reverse=false;
        
        switch(type){
            case "KEYS":
                this.#addKeyboardListeners();
                break;
            case "DUMMY":
                this.forward=true;
                break;
            case "PROLOG":
                // this.updateProlog();
                break;
        }
    }

    updateJSONKeys(controls) {
        //console.log(controls);
        this.forward = (controls.forward)?true:false;
        this.reverse = (controls.reverse)?true:false;
        this.left = (controls.left)?true:false;
        this.right = (controls.right)?true:false;
        //console.log('forward: '+this.forward+' ('+controls.forward+') -- reverse: '+this.reverse+' ('+controls.reverse+') -- '+
        //            'left: '+this.left+' ('+controls.left+') -- right: '+this.right+' ('+controls.right+')')
    }

    updateProlog(sensors, x, y, angle) {
        var s1=sensors[0], s2=sensors[1], s3=sensors[2], s4=sensors[3], s5=sensors[4];
        if (x==undefined || y ==undefined || angle== undefined || s1==undefined ||
            s2==undefined || s3==undefined || s4==undefined || s5==undefined ) return;
        var URL = ("./action?"+
                   "s1="+s1+"&s2="+s2+"&s3="+s3+"&s4="+s4+"&s5="+s5+
                   "&x="+x+"&y="+y+"&angle="+angle);
        //console.log(URL);
        $.getJSON(
            URL,
            this.updateJSONKeys.bind(this)
        );
    }

    #addKeyboardListeners(){
        document.onkeydown=(event)=>{
            switch(event.key){
                case "ArrowLeft":
                    this.left=true;
                    break;
                case "ArrowRight":
                    this.right=true;
                    break;
                case "ArrowUp":
                    this.forward=true;
                    break;
                case "ArrowDown":
                    this.reverse=true;
                    break;
            }
        }
        document.onkeyup=(event)=>{
            switch(event.key){
                case "ArrowLeft":
                    this.left=false;
                    break;
                case "ArrowRight":
                    this.right=false;
                    break;
                case "ArrowUp":
                    this.forward=false;
                    break;
                case "ArrowDown":
                    this.reverse=false;
                    break;
            }
        }
    }
}
