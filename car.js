class Car{
    constructor(x,y,width,height,roadwidth,controlType,maxSpeed=3,color="lightBlue"){
        this.x=x;
        this.y=y;
        this.width=width;
        this.height=height;
        this.roadwidth = roadwidth;

        this.speed=0;
        this.acceleration=0.2;
        this.maxSpeed=maxSpeed;
        this.friction=0.05;
        this.angle=0;
        this.controlType = controlType;
        this.steps = 0;
        this.small_steps = 0;
        this.damage = false;
        this.sensor=new Sensor(this);

        this.controls=new Controls(controlType);
        this.polygon=this.#createPolygon();
        this.img=new Image();
        this.img.src="car.png"

        this.mask=document.createElement("canvas");
        this.mask.width=width;
        this.mask.height=height;

        const maskCtx=this.mask.getContext("2d");
        this.img.onload=()=>{
            maskCtx.fillStyle=color;
            maskCtx.rect(0,0,this.width,this.height);
            maskCtx.fill();

            maskCtx.globalCompositeOperation="destination-atop";
            maskCtx.drawImage(this.img,0,0,this.width,this.height);
        }
    }

    update(roadBorders,traffic){
        if (this.controlType == "PROLOG") {
            this.controls.updateProlog(this.getSensors(), this.x, this.y, this.angle);
        }
        this.#move();
        this.polygon=this.#createPolygon();
        if (this.#assessDamage(roadBorders,traffic)) {
            this.damage = true;
            this.#collision();
        }else{
            this.damage = false;
        }
        if(this.sensor){
            this.sensor.update(roadBorders,traffic);
        }
    }

    getSensors() {
        if(this.sensor){
            const offsets=this.sensor.readings.map(
                s=>s==null?0:1-s.offset
            );
            return offsets;
        }else{
            return [0,0,0,0,0];
        }
    }

    #assessDamage(roadBorders,traffic){
        for(let i=0;i<roadBorders.length;i++){
            if(polysIntersect(this.polygon,roadBorders[i])){
                return true;
            }
        }
        for(let i=0;i<traffic.length;i++){
            if(polysIntersect(this.polygon,traffic[i].polygon)){
                return true;
            }
        }
        return false;
    }

    #createPolygon(){
        const points=[];
        const rad=Math.hypot(this.width,this.height)/2;
        const alpha=Math.atan2(this.width,this.height);
        points.push({
            x:this.x-Math.sin(this.angle-alpha)*rad,
            y:this.y-Math.cos(this.angle-alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(this.angle+alpha)*rad,
            y:this.y-Math.cos(this.angle+alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(Math.PI+this.angle-alpha)*rad,
            y:this.y-Math.cos(Math.PI+this.angle-alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(Math.PI+this.angle+alpha)*rad,
            y:this.y-Math.cos(Math.PI+this.angle+alpha)*rad
        });
        return points;
    }

    async #move(){
        if (this.controlType == "PROLOG")
            this.controls.updateProlog(this.getSensors());
        if(this.controls.forward){
            this.speed+=this.acceleration;
        }
        if(this.controls.reverse && !this.damage){
            this.speed-=this.acceleration;
        }

        if(this.speed>this.maxSpeed){
            this.speed=this.maxSpeed;
        }
        if(this.speed<-this.maxSpeed/2){
            this.speed=-this.maxSpeed/2;
        }

        if(this.speed>0){
            this.speed-=this.friction;
        }
        if(this.speed<0){
            this.speed+=this.friction;
        }
        if(Math.abs(this.speed)<this.friction){
            this.speed=0;
        }

        if(this.speed!=0){
            if (this.controlType == "DUMMY")
                this.#getDummyAngle();
            const flip=this.speed>0?1:-1;
            if(this.controls.left){
                this.angle+=0.03*flip;
            }
            if(this.controls.right){
                this.angle-=0.03*flip;
            }
        }

        this.x-=Math.sin(this.angle)*this.speed;
        this.y-=Math.cos(this.angle)*this.speed;

        //if (this.controlType == "KEYS" || this.controlType == "PROLOG")
        //    console.log(this.angle);
    }

    async #getDummyAngle() {
        if (this.x < this.width) {
            this.angle = -.1;
            this.small_steps++;
        }else if (this.x > this.roadwidth - (this.width)) {
            this.angle = .1;
            this.small_steps++;
        }else if (this.angle != 0 && this.steps > 100) {
            this.angle = 0;
            this.steps = 0;
        }else{
            if (Math.random() < 0.2) {
                if (this.small_steps > 10) {
                    if (Math.random() <= 0.5)
                        this.angle = Math.random()*.4;
                    else
                        this.angle = Math.random()*-.4;
                    this.small_steps=0;
                }else{
                    this.small_steps++;
                }
            }
            this.steps++;
        }
    }

    async #collision() {
        var old_speed = this.speed, sensors, inc=1.5;
        const flip=this.speed>0?1:-1;
        if(this.controls.left){
            this.angle+=0.03*flip;
        }
        if(this.controls.right){
            this.angle-=0.03*flip;
        }
        sensors = this.getSensors();
        for (var i=0;i<sensors.length;i++)
            if (sensors[i] > 0.8) this.speed = -0.2;
        this.x-=Math.sin(this.angle)*this.speed*inc;
        this.y-=Math.cos(this.angle)*this.speed*inc;
        if (this.controlType == "DUMMY")
            inc = 0.2;
        else
            inc = 0.01;
        this.speed = (old_speed>0)?old_speed*inc:old_speed*inc;
    }

    draw(ctx,drawSensor=false){
        ctx.save();
        ctx.translate(this.x,this.y);
        ctx.rotate(-this.angle);
        ctx.drawImage(this.mask,
            -this.width/2,
            -this.height/2,
            this.width,
            this.height);
        ctx.globalCompositeOperation="multiply";
        ctx.drawImage(this.img,
            -this.width/2,
            -this.height/2,
            this.width,
            this.height);
        ctx.restore();

        if(this.sensor && drawSensor){
            this.sensor.draw(ctx);
        }
    }
}
