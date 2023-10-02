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

Por exemplo, no código abaixo.
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTA3MTc5ODIwOSw1NDkwMDcwODIsLTUxMT
M3MjQ5Miw1NDkxOTAwMTQsMTkyODU1Nzk2OCw1MDU5NjIzNCw3
MzA5OTgxMTZdfQ==
-->