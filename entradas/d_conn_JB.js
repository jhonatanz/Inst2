//Programa para dibujar los diagramas de conexionado

var docu = this.getDocument();
var tipo_borne;
var tipo_cable_I;
var tipo_cable_J;
var tipo_inst;

// Definicion de variables de inicializacion del loop, se recorre el arreglo diag
var i_max = diag.length;
var j = 0;
var k = 0;
var ts_prev = 0;

for (var i = 0; i < i_max; i++) {
	// Definicion de variables dentro del loop
	var b;
	var position;
	var scale;
	var angle;
	var bref;
    var Tag_Sig = diag[i][0];
    var Origen = diag[i][1];
    var Tipo_Sig = diag[i][2];
    var Cable1 = diag[i][3];
    var Par1 = diag[i][4];
    var JTS = diag[i][5];
    var Jborne1 = diag[i][6];
    var Jborne2 = diag[i][7];
    var Jborne3 = diag[i][8];
    var Jborne4 = diag[i][9];
    var Cable2 = diag[i][10];
    var Par2 = diag[i][11];
    var Dest = diag[i][12];
    var Cntrl = diag[i][13];

	// Dibuja la portada
	if(i == 0){
		b = docu.getBlockId("A4_vert_JZ");
		position = new RVector(10+210*k, 10);
		scale = new RVector(1,1);
		angle = RMath.deg2rad(0);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
		addSimpleText(text = "DIAGRAMA DE CONEXIONADO", [105, 160], height = 6, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true)
		addSimpleText(text = Dest , [105, 152], height = 6, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true)
	}
	//cambio de hoja
	if (j >= 45 | ts_prev != JTS) {
		k = k+1;
		j = 0;
		b = docu.getBlockId("A4_vert_JZ");
		position = new RVector(10+210*k, 10);
		scale = new RVector(1,1);
		angle = RMath.deg2rad(0);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
		addSimpleText(text = JTS, [130+210*k, 253], height = 3, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true) //pone el TS en cada pagina
	}
	// Seleccion de bloque a usar dependiendo del tipo de señal
	switch(Tipo_Sig) {
	case "D":
		tipo_inst = "Inst";
		tipo_borne_J = "bornes_D";
		tipo_cable_I = "cable_ID";
		tipo_cable_J = "cable_JD";
		cond_par = 2;
		break;
	case "A":
		tipo_inst = "Inst";
		tipo_borne_J = "bornes_A";
		tipo_cable_I = "cable_IA";
		tipo_cable_J = "cable_JA";
		cond_par = 3;
		break;
	case "R":
		tipo_inst = "Inst_RTD";
		tipo_borne_J = "bornes_R";
		tipo_cable_I = "cable_IR";
		tipo_cable_J = "cable_JR";
		cond_par = 4;
		break;
	case "T":
		tipo_inst = "Inst";
		tipo_borne_J = "bornes_D";
		tipo_cable_I = "cable_ID";
		tipo_cable_J = "cable_JD";
		cond_par = 2;
		break;
	}
	
	//dibuja el bloque de la señal//
	if (Tag_Sig != "RESERVA" & Cable1.search("JBI") ==-1) {
		b = docu.getBlockId(tipo_inst);
		position = new RVector(30+210*k,250-4*j);
		scale = new RVector(1,1);
		angle = RMath.deg2rad(0);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
	}
	
	//dibuja el bloque del cable desde instrumento//
	if (Cable1 != "NA") {
		b = docu.getBlockId(tipo_cable_I);
		position = new RVector(30+210*k,250-4*j);
		scale = new RVector(1,1);
		angle = RMath.deg2rad(0);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
	}
	
	//dibuja el bloque de la bornera asociado a la señal que recibe desde instrumento//
	b = docu.getBlockId(tipo_borne_J);
	position = new RVector(30+210*k,250-4*j);
	scale = new RVector(1,1);
	angle = RMath.deg2rad(0);
	bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
	addObject(bref);

	//dibuja el bloque del cable desde la caja, hacia el gabinete
	
	b = docu.getBlockId(tipo_cable_J);
	position = new RVector(30+210*k,250-4*j);
	scale = new RVector(1,1);
	angle = RMath.deg2rad(0);
	bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
	addObject(bref);
	
	//generacion de textos
	
	//Agrega el texto de la señal, el origen, el cable1 y el par1 si existe cable1
	if (Cable1 != "NA") {
		addSimpleText(text = Tag_Sig, [39.5+210*k, 248.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el tag de la señal (Tag_Sig)
		if(Cable1 .search("JBI")==-1){
			addSimpleText(text = "("+Origen+")", [39.5+210*k, 244.2-4*j] , height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el tag de JBI de origen//
		}else{
			addSimpleText(text = "("+Dest+")", [39.5+210*k, 244.2-4*j] , height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el tag de JBI de origen//
		}
		addSimpleText(text = Cable1, [86+210*k, 250-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //tag del cable de inst a caja (cable1)//
		addSimpleText(text = "PAR " + Par1, [86+210*k, 246.4-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //numero del par del cable del inst (par1)
	}
	//Agrega el texto de las borneras
	addSimpleText(text = Jborne1, [130+210*k, 248.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el numero del borne (Bornes_JB)//
	addSimpleText(text = Jborne2, [130+210*k, 244.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el numero del borne (Bornes_JB)//
	switch(Tipo_Sig){
		case "A":
		addSimpleText(text = Jborne3, [130+210*k, 240.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el numero del borne (Bornes_JB),  caso señal analoga
		break;
		case "R":
		addSimpleText(text = Jborne3, [130+210*k, 240.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el numero del borne (Bornes_JB),  caso señal RTD
		addSimpleText(text = Jborne4, [130+210*k, 236.2-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //pone el numero del borne (Bornes_JB),  caso señal RTD
		break;
	}
	//Agrega el texto del cable2 y par2
	if(Cable2 != "NA"){
		addSimpleText(text = Cable2 + " a (" + Cntrl + ")", [168+210*k, 250-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //tag del cable de caja a gabinete (cable2)//
		addSimpleText(text = "PAR " + Par2, [168+210*k, 246.4-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter) //numero del par del cable2 (par2)
	}else{
		addSimpleText(text = "Por Vendedor a (" + Cntrl + ")", [168+210*k, 250-4*j], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter)
	}
	//actualizacion variables loop
	j = j+cond_par;
	ts_prev = JTS;
}
