import wollok.game.*
import configuracion.*
import direcciones.*

object faltaAgregar
{
	
}

class GenericObject
{
	const property tipo
	const tiposQueChocaContra 
	const property image
	var property position

	method impactarContra(objeto)
	{
		if (self.puedeChocarContra(objeto)) objeto.aplicarEfectoSobre(self)
	}
	

	method aplicarEfectoSobre(objeto)

	method morir() { game.schedule(100,{game.removeVisual(self)})}
	
	method puedeChocarContra(objeto) = tiposQueChocaContra.contains(objeto.tipo()) 
}

class MovingObject inherits GenericObject
{
const velocidad

method seMueve() = true

method desplazar() 
{
position = arriba.movimientoVertical(self.position(),velocidad)
}

}

class TextObject 
{
	const property tipo = "Texto"
    method puedeChocarContra(objeto) = false
    method seMueve() = false

}

object avion inherits GenericObject(tipo = "Avion", tiposQueChocaContra = ["Asteroide","Provision"], position = game.at(game.center().x(),0), image = "avion.png")
{
	const arma = rifle
	var armadura = carcaza
	
	
	method seMueve() = false // No se mueve automaticamente

   method reducirVida(cuanto) {
   	
   	carcaza.reducirVida(cuanto)
   }

   method moverHacia(direccion)
	{
		position = direccion.proximaPosicion(position)
	}


	override method aplicarEfectoSobre(objetoQueChoca)
	{
		objetoQueChoca.morir()
	}


   method dispara() {arma.disparar()}

   method cambiarMunicion() {arma.cambiarSelector()}
	
	method agregarMunicion(cartucho){}
}

object carcaza
{
	var vida = 1
	method reducirVida(cuanto)
    { 
		vida  -= cuanto
        if(vida <= 0) configuracion.gameOver()
    }
}

object rifle
{
const cartuchos = [cartuchoDefault,cartuchoGrande]
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

//object contadorDeMunicion inherits TextObject{}

method lanzarProjectil(bala)
{
const balaADisparar = bala.crearTemplateBala()
game.addVisual(balaADisparar)
configuracion.configurarColision(balaADisparar)
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
}

method reducirVida(_danio)
{
vida -= _danio
if (self.sinVida()) self.morir()
}

}

object cartuchoDefault inherits Cartucho (bala = balaDefault,cantidadDeBalas = 30){}

object cartuchoGrande inherits Cartucho (bala = balaGrande,cantidadDeBalas = 10) {}

object balaDefault inherits TemplateBala(danio = 1, imagen = "misil_chico.png", velocidad = 1){}
object balaGrande inherits  TemplateBala(danio = 1, imagen = "misil_grande.png", velocidad = 0.3){}




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

object lanzadorDeAsteroide
{
	const listaDeTemplates = [new TemplateAsteroide(danio =1, imagen = "asteroideChiquitin.png", velocidad = -0.3, puntaje = 100,vida = 1),new TemplateAsteroide(danio =1, imagen = "asteroideMediano.png", velocidad = -0.2, puntaje = 200,vida = 2),new TemplateAsteroide(danio =1, imagen = "asteroideGrande.png", velocidad = -0.1, puntaje = 300,vida = 3)]
	
	method lanzar()
	{
		const asteroideElegido = listaDeTemplates.anyOne().crearTemplateAsteroide()
		game.addVisual(asteroideElegido)
		configuracion.configurarColision(asteroideElegido)
	}
}

object lanzarDeProvisiones
{
	
}

class TemplateAsteroide
{
	const property danio
	const property imagen
	const property velocidad
	const property puntaje
	const vida 
	
	method crearTemplateAsteroide() = new Asteroide(danio = danio, vida = vida, puntaje = puntaje, velocidad = velocidad, image = imagen, position = game.at(0.randomUpTo(game.width()),game.height()))

}

class TemplateBala 
{
	const property danio
	const property imagen
	const property velocidad
	method crearTemplateBala() = new Bala(velocidad = self.velocidad(), image = self.imagen(), position = avion.position(), danio = self.danio())
	
}