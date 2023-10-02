---
title: "O qualificador 'restrict' em C"
date: 2023-09-26T18:23:03-04:00
authors: ["Mayco S. Berghetti"]
tags: [ "C" ]
categories: [
    "programming"
]
draft: false
---

O qualificador *restrict* diz ao compilador que um ponteiro não tem um *aliasing*, ou seja, não existe outro ponteiro que modifique o objeto.

Usar *restrict* possibilita que o compilador possa otimizar melhor o código.
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTg1MDk5MDI0NCwtNjAxNjY5Njk0XX0=
-->