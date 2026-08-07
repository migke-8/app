//> using scala 3.3.8
//> using platforms scalajs JVM
//> using dep com.softwaremill.sttp.tapir::tapir-core:1.13.31

import sttp.tapir.*
import java.io.File
import scala.quoted.*
import java.nio.file.Files
import java.nio.file.Paths

object Data {
  val helloPoint = endpoint.get
    .in("")
    .out(htmlBodyUtf8)
}
