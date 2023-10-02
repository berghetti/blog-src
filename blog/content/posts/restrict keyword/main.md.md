---
title: "O qualificador 'restrict' em C"
date: 2023-09-26T18:23:03-04:00
authors: ["Mayco S. Berghetti"]
tags: [ "C" ]
categories: [
    "programming"
]
draft: true
---

O qualificador `restrict` diz ao compilador que um ponteiro não tem um `aliasing`, ou seja, que não existe outro ponteiro que modifique o objeto.

Por exemplo, tome o código abaixo.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEwNTIzMjEzMTAsNTQ5MDA3MDgyLC01MT
EzNzI0OTIsNTQ5MTkwMDE0LDE5Mjg1NTc5NjgsNTA1OTYyMzQs
NzMwOTk4MTE2XX0=
-->