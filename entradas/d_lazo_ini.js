
// Programa para generacion automatica de lazos
var docu = this.getDocument();
var b;
var position;
var scale;
var angle;
var bref;
var Bloque_ini;
var Bloque_fin;
var Posx_ini;

// Formato para la portada y el indice

b = docu.getBlockId("A4_hor_JZ");
position = new RVector(10, 10);
scale = new RVector(1,1);
angle = RMath.deg2rad(0);
bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
addObject(bref);
addSimpleText(text = "DIAGRAMA DE LAZOS", [148.5, 114], height = 6, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true);

b = docu.getBlockId("A4_hor_JZ");
position = new RVector(10+297, 10);
scale = new RVector(1,1);
angle = RMath.deg2rad(0);
bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
addObject(bref);
addSimpleText(text = "INDICE", [148.5+297, 167], height = 5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true);

// Encuentro la cantidad de paginas
var c_pag = diag.length;
for(var i = 0; i < c_pag; i++){
	var fil  = diag[i][0][0][41];
	var col = diag[i][0][0][42];
	// Formato
	b = docu.getBlockId("A4_hor_JZ");
	position = new RVector(10+297*col, 10-210*fil);
	bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
	addObject(bref);
	addSimpleText(text = "LAZO " + diag[i][0][0][3], [229.5+297*col, 32.5-210*fil], height = 2.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true);
	addSimpleText(text = diag[i][0][0][4] , [229.5+297*col, 27.5-210*fil], height = 2, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true); // Servicio
	addSimpleText(text = diag[i][0][0][39] + " de " + (c_pag+2), [266+297*col, 18-210*fil], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true); // hoja de hojas
	// Dibuja la grilla del lazo
	b = docu.getBlockId("loop_grid");
	position = new RVector(20+297*col, 53-210*fil);
	bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
	addObject(bref);
	// Dibuja el bloque de notas
	b = docu.getBlockId("Notas");
	position = new RVector(20+297*col, 15-210*fil);
	bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
	addObject(bref);
	// Encuentra la cantidad de señales en la pagina
	var s_pag = diag[i].length;
	for(j = 0; j < s_pag; j++){
		// Altura del bloque de señal
		var h = diag[i][j][0][38]-diag[i][j][0][37];
		// Selección del bloque apropiado
		switch(diag[i][j][0][13]) {
		case "D":
			Bloque_ini = "BloqueX_Dig_YY";
			Bloque_fin = "Bloque3_Dig";
			break;
		case "A":
			Bloque_ini = "BloqueX_Ana_YY";
			Bloque_fin = "Bloque3_Ana";
			break;
		case "R":
			Bloque_ini = "BloqueX_RTD_YY";
			Bloque_fin = "Bloque3_RTD";
			break;
		case "T":
			Bloque_ini = "BloqueX_Ana_YY";
			Bloque_fin = "Bloque3_Ana";
			break;
		}
		// Seleccion del bloque inicial dependiendo de si va a caja
		if(diag[i][j][0][20] == "NA"){
			Bloque_ini = Bloque_ini.replace("YY", "GB")
		}else{
			Bloque_ini = Bloque_ini.replace("YY", "JB")
			addSimpleText(text = diag[i][j][0][19], [170+297*col, 139.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Cable2
			addSimpleText(text = "PAR " + diag[i][j][0][20], [170+297*col, 136.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Par2
			addSimpleText(text = diag[i][j][0][14], [148.5+297*col, 162.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //JBI
			addSimpleText(text = diag[i][j][0][24], [148.5+297*col, 160.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //TS en JBI
			addSimpleText(text = diag[i][j][0][20], [148.5+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Jborne1
			addSimpleText(text = diag[i][j][0][21], [148.5+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Jborne2
			if(diag[i][j][0][13] == "A" | diag[i][j][0][13] == "R"){
				addSimpleText(text = diag[i][j][0][22], [148.5+297*col, 145.125-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Jborne3
			}
			if(diag[i][j][0][13] == "R"){
				addSimpleText(text = diag[i][j][0][23], [148.5+297*col, 139.875-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Jborne4
			}
		}
		// Seleccion del bloque inicial dependiendo de la localizacion del origen de la señal
		switch(diag[i][j][0][2]) {
		case "FLD":
			Bloque_ini = Bloque_ini.replace("X", "1")
			Posx_ini = 45.7;
			addSimpleText(text = diag[i][j][0][1], [48+297*col, 161-210*fil-h], height = 2.2, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true); //Origen
			addSimpleText(text = diag[i][j][0][0].substring(0, diag[i][j][0][0].indexOf("-")), [45.7+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig arriba
			addSimpleText(text = diag[i][j][0][0].substring(diag[i][j][0][0].indexOf("-")+1, diag[i][j][0][0].length), [45.7+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig abajo
			addSimpleText(text = diag[i][j][0][16], [97+297*col, 157.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Cable1
			addSimpleText(text = "PAR " + diag[i][j][0][17], [97+297*col, 153.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Par1
			break;
		case "CCM":
			Bloque_ini = Bloque_ini.replace("X", "2")
			Posx_ini = 97.1;
			addSimpleText(text = diag[i][j][0][1], [99.4+297*col, 161-210*fil-h], height = 2.2, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter, bold = true); //Origen
			addSimpleText(text = diag[i][j][0][0].substring(0, diag[i][j][0][0].indexOf("-")), [97.1+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig arriba
			addSimpleText(text = diag[i][j][0][0].substring(diag[i][j][0][0].indexOf("-")+1, diag[i][j][0][0].length), [97.1+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig abajo
			if(Bloque_ini == "Bloque2_Ana_JB" | Bloque_ini == "Bloque2_Dig_JB"){
				addSimpleText(text = diag[i][j][0][16], [122.5+297*col, 139.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Cable1
				addSimpleText(text = "PAR " + diag[i][j][0][17], [122.5+297*col, 136.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Par1
			}else{
				addSimpleText(text = diag[i][j][0][16], [148.4+297*col, 157.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Cable1
				addSimpleText(text = "PAR " + diag[i][j][0][17], [148.4+297*col, 153.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Par1
			}
			break;
		}
		
		// Bloque inicial
		b = docu.getBlockId(Bloque_ini);
		position = new RVector(Posx_ini+297*col, 153-210*fil-h);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
		
		//Bloque final
		b = docu.getBlockId(Bloque_fin);
		position = new RVector(148.5+297*col, 150.375-210*fil-h);
		bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
		addObject(bref);
		
		// Textos correspondientes al bloque final de cada señal
		addSimpleText(text = diag[i][j][0][15].replace("PLC", "GAB"), [191.375+297*col, 162.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //GAB
		addSimpleText(text = diag[i][j][0][31], [191.375+297*col, 160.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //TS en GAB
		addSimpleText(text = diag[i][j][0][27], [191.375+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Gborne1
		addSimpleText(text = diag[i][j][0][28], [191.375+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Gborne2
		if(diag[i][j][0][13] == "A" | diag[i][j][0][13] == "R"){
			addSimpleText(text = diag[i][j][0][29], [191.375+297*col, 145.125-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Gborne3
		}
		if(diag[i][j][0][13] == "R"){
			addSimpleText(text = diag[i][j][0][30], [191.375+297*col, 139.875-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Gborne4
		}
		addSimpleText(text = diag[i][j][0][35], [216.45+297*col, 162.75-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Rack
		addSimpleText(text = diag[i][j][0][34], [216.45+297*col, 160.25-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Modulo
		addSimpleText(text = diag[i][j][0][33], [216.7+297*col, 155.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Canal
		addSimpleText(text = diag[i][j][0][5], [216.7+297*col, 150.5-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tipo De IO
		addSimpleText(text = diag[i][j][0][0].substring(0, diag[i][j][0][0].indexOf("-")), [251+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig arriba
		addSimpleText(text = diag[i][j][0][0].substring(diag[i][j][0][0].indexOf("-")+1, diag[i][j][0][0].length), [251+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig abajo
		if(diag[i][j][0][9] != "NA"){
			// Textos si hay interlock
			addSimpleText(text = diag[i][j][0][9].substring(0, diag[i][j][0][9].indexOf("-")), [261.5+297*col, 155.625-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig arriba
			addSimpleText(text = diag[i][j][0][9].substring(diag[i][j][0][9].indexOf("-")+1, diag[i][j][0][9].length), [261.5+297*col, 150.375-210*fil-h], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tag_Sig abajo
			// Bloque si hay interlock
			b = docu.getBlockId("Inter");
			position = new RVector(261.5+297*col, 153-210*fil - h);
			bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
			addObject(bref);
		}
		if(diag[i][j][0][10] == "SI"){
			addSimpleText(text = "LOG", [242+297*col, 150.5-210*fil-h], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Log de eventos
		}
		if(diag[i][j][0][11] == "SI"){
			addSimpleText(text = "TEND", [242+297*col, 149-210*fil-h], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tendencia
		}
		if(diag[i][j][0][12] == "SI"){
			addSimpleText(text = "HIST", [242+297*col, 147.5-210*fil-h], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Historico
		}
		
		// Encuentro la cantidad de señales soft en la señal
		var s_sig = diag[i][j].length-1;
		if(s_sig>0){
			for(k = 0; k < s_sig; k++){
				b = docu.getBlockId("signal");
				position = new RVector(251+297*col, 142.5-210*fil - h - 10.5*k);
				bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
				addObject(bref);
				//Tag_Sig arriba
				addSimpleText(text = diag[i][j][k+1][0].substring(0, diag[i][j][k+1][0].indexOf("-")), [251+297*col, 145.125-210*fil-h-10.5*k], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); 
				//Tag_Sig abajo
				addSimpleText(text = diag[i][j][k+1][0].substring(diag[i][j][k+1][0].indexOf("-")+1, diag[i][j][k+1][0].length), [251+297*col, 139.875-210*fil-h-10.5*k], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter);
				if(diag[i][j][k+1][10] == "SI"){
					addSimpleText(text = "LOG", [242+297*col, 140-210*fil-h-10.5*k], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Log de eventos
				}
				if(diag[i][j][k+1][11] == "SI"){
					addSimpleText(text = "TEND", [242+297*col, 138.5-210*fil-h-10.5*k], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Tendencia
				}
				if(diag[i][j][k+1][12] == "SI"){
					addSimpleText(text = "HIST", [242+297*col, 137-210*fil-h-10.5*k], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Historico
				}
				if(diag[i][j][k+1][9] != "NA"){
					// Textos si hay interlock
					//Tag_Sig arriba
					addSimpleText(text = diag[i][j][k+1][9].substring(0, diag[i][j][k+1][9].indexOf("-")), [261.5+297*col, 145.125-210*fil-h-10.5*k], height = 1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); 
					//Tag_Sig abajo
					addSimpleText(text = diag[i][j][k+1][9].substring(diag[i][j][k+1][9].indexOf("-")+1, diag[i][j][k+1][9].length), [261.5+297*col, 139.875-210*fil-h-10.5*k], height=1.5, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); 
					addSimpleText(text = "CNTR", [242+297*col, 141.5-210*fil-h-10.5*k], height = 1, angle = 0, font = "Liberation Sans", RS.VAlignMiddle, RS.HAlignCenter); //Controlador (obligatorio si tiene asociado un interlock)
					// Bloque si hay interlock
					b = docu.getBlockId("Inter");
					position = new RVector(261.5+297*col, 142.5-210*fil - h - 10.5*k);
					bref = new RBlockReferenceEntity(docu, new RBlockReferenceData(b, position, scale, angle));
					addObject(bref);
				}
			}
		}
	}
}

