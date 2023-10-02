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

O qualificador *restrict* diz ao compilador que um ponteiro não tem um *aliasing*, ou seja, não existe outro ponteiro que modifique o objeto.

Por exemplo, no código abaixo.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTYwMTY2OTY5NCwxMDcxNzk4MjA5LDU0OT
AwNzA4MiwtNTExMzcyNDkyLDU0OTE5MDAxNCwxOTI4NTU3OTY4
LDUwNTk2MjM0LDczMDk5ODExNl19
-->