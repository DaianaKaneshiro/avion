import wollok.game.*
import ArchivoGeneral.*
import direcciones.*


object configuracion {
	
	method configuracionDeJuego(){
		game.clear()
		game.addVisual(avion)	
		game.addVisual(pointTracker)	
		pointTracker.reset()
		game.boardGround("espacio.png")
		self.configurarColision(avion)
		self.configurarTeclas()
		game.onTick(150,"Actualizar todas las posiciones" ,{self.actualizarPosiciones()})
		game.onTick(1000, "Lanzar asteroide", {lanzadorDeAsteroide.lanzar()})
	}
	
	method configurarColision(objeto)
	{
		game.onCollideDo(objeto,{objetoQueChoca => objeto.impactarContra(objetoQueChoca)})
	}

	method configurarTeclas(){
		keyboard.left().onPressDo({avion.moverHacia(izquierda) })
		keyboard.up().onPressDo({ avion.moverHacia(arriba) })
		keyboard.right().onPressDo({avion.moverHacia(derecha) })
		keyboard.down().onPressDo({avion.moverHacia(abajo) })
		keyboard.space().onPressDo({avion.dispara()})
		keyboard.q().onPressDo({avion.cambiarMunicion()})
		//keyboard.z().onPressDo({avion.dispara(balaTriple)})
		//keyboard.x().onPressDo({avion.dispara(balaChica)})
	}
	

	method mainMenu()
	{
		game.clear()
		game.boardGround("espacio.png")
		game.addVisual(object { method image() = "comenzar.png" method position() = game.at(2,13)})
		game.addVisual(object { method image() = "controles.png" method position() = game.at(2,9)})
		game.addVisual(object { method image() = "salir.png" method position() = game.at(2,5)})
		keyboard.w().onPressDo({self.configuracionDeJuego()})
		keyboard.q().onPressDo({self.controles()}) 
		keyboard.s().onPressDo({game.stop()})
	} 
	
	method gameOver()
	{
		self.mainMenu()
		game.addVisual(object { method text() = "El puntaje final fue " + pointTracker.puntajeAcumulado().toString() method position() = game.center()})
	}
	
	method controles(){
		game.clear()
		game.boardGround("espacio.png")
		game.addVisual(object { method image() = "controles.png" method position() = game.center()})
		keyboard.w().onPressDo({self.mainMenu()})
	}
	
	method impacto(x,y)
	{
	x.chocarContra(y)
	y.chocarContra(x)
	}
	
	
	method actualizarPosiciones()
	{
		game.allVisuals().filter({x => x.seMueve()}).forEach({x => x.desplazar()})
	}
	
	
}


object pointTracker inherits TextObject 
{
	
	var property puntajeAcumulado = 0
	
	method reset()
	{
		puntajeAcumulado = 0
	}
	
	
	
	method position() = game.at(20,20)
	
	method aumentarPuntaje(x)
	{
		puntajeAcumulado = puntajeAcumulado + x
	}
	
	method bajarVida()
	{}
	
	method text() = puntajeAcumulado.toString()
	
	
	method textColor() = "00FF00FF"
	
}



