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

O qualificador `restrict` diz ao compilador que um determinado ponteiro não possui `aliasing`. Ou seja, que o objeto, que o ponteiro aponta, não é referenciado, e principalmente modificado, por outro ponteiro.
<!--stackedit_data:
eyJoaXN0b3J5IjpbNTQ5MDA3MDgyLC01MTEzNzI0OTIsNTQ5MT
kwMDE0LDE5Mjg1NTc5NjgsNTA1OTYyMzQsNzMwOTk4MTE2XX0=

-->