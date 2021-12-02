package com.pret.piter

import io.micronaut.http.MediaType
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.Produces

@Controller("/another")
class AnotherController {

    @Produces(MediaType.TEXT_PLAIN)
    @Get
    fun pret(): String {
        return "Am I working fine?"
    }
}
