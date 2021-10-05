import wollok.game.*

object faltaAgregar
{
	
}

class GenericObject
{
	const tipo
	const tiposQueChocaContra 
	const property image
	var property position

	method impactarContra(objeto)
	{
		if (self.puedeChocarContra(objeto)) objeto.aplicarEfectoSobre(self)
	}
	

	method aplicarEfectoSobre(objeto)

	method morir() { game.removeVisual(self)}
	
	method puedeChocarContra(objeto) = tiposQueChocaContra.contains(objeto.tipo()) 
}

class MovingObject inherits GenericObject
{
const velocidad

method seMueve() = true

method desplazar() 
{
position = position.movimientoVertical(velocidad)
}

}

class TextObject 
{
    method puedeChocarContra(objeto) = false
    method seMueve() = false

}

object avion inherits GenericObject(tipo = "Avion", tiposQueChocaContra = ["Asteroide","Provision"], position = game.at(0,game.center()), image = "avion.png")
{
	const rifle = faltaAgregar
	var carcaza = faltaAgregar

  method reducirVida(cuanto) {carcaza.reducirVida(cuanto)}

   method moverHacia(direccion)
	{
		position = direccion.proximaPosicion(position)
	}


	override method aplicarEfectoSobre(objetoQueChoca)
	{
		objetoQueChoca.morir()
	}


   method dispara() {rifle.disparar()}

   method cambiarMunicion() {rifle.cambiarSelector()}
	
}

object carcaza
{
	var vida = 1
	method reducirVida(cuanto)
    { 
		vida  -= cuanto
        if(vida <= 0) configuracion.GameOver()
    }
}

object Rifle
{
const cartuchos = []
var selectorCartucho = 0


method disparar()
{
const cartuchoQueSeDispara = cartuchos.get(selectorCartucho)

if (cartuchoQueSeDispara.tieneBalas())
{
cartuchoQueSeDispara.consumirBala()
self.lanzarProjectil(cartuchoQueSeDispara.bala())
}
}

method lanzarProjectil(bala)
{
const balaADisparar = new Bala(velocidad = bala.velocidad(), image = bala.imagen(), position = avion.position(), danio = bala.danio())
game.addVisual(balaADisparar)
}


method cambiarSelector()
{
selectorCartucho = (selectorCartucho + 1).rem(cartuchos.size())
}

}


class Cartucho
{
var property bala

var cantidadDeBalas

method consumirBala() {cantidadDeBalas -= 1}

method tieneBalas() = cantidadDeBalas > 0
}

class Asteroide inherits MovingObject(tipo = "Asteroide", tiposQueChocaContra = ["Bala","Avion"])
{
const danio
var vida
const property puntaje 
method sinVida() = vida <= 0


override method aplicarEfectoSobre(objetoQueChoca)
{
	objetoQueChoca.reducirVida(danio)
     if (self.sinVida()) self.morir()
}

method reducirVida(danio)
{
vida -= danio
if (self.sinVida()) self.morir()
}




class BalaQueSeDispara
{

}


class Bala inherits MovingObject(tipo  = "Bala", tiposQueChocaContra = ["Asteroide", "Provision"])
{
const danio
method reducirVida(x){self.morir()}

override method aplicarEfectoSobre(objetoQueChoca)
{

objetoQueChoca.reducirVida(danio)

if (objetoQueChoca.tipo() == "Asteroide" and objetoQueChoca.sinVida()) 
{
pointTracker.aumentarPuntaje(objetoQueChoca.puntaje())
}

}

}

class Provision inherits MovingObject(velocidad = 1, tiposQueChocaContra = ["Avion"])
{
const cartucho

method reducirVida(danio){self.morir()}

override method aplicarEfectoSobre(Avion)
{
avion.agregarMunicion(cartucho)
}

}