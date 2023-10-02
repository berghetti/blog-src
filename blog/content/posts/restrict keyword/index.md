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

O qualificador *restrict* diz ao compilador que um ponteiro não tem um *aliasing*, ou seja, não existe outro ponteiro que modifique o objeto. Por exemplo, uma função que possui a assinatura `int f(int *a, int *b)`, os ponteiros `a` e `b` podem apontar para o mesmo objeto. O compilador tem que levar isso em consideração ao gerar o código.

Se sabemos que os ponteiros não apontam para o mesmo objeto, dizemos isso ao compilador usando a palavra-chave *restrict*.  Isso permite que o código possa ser melhor otimizado.

```c
int f(int *a, int *b)
{
  
}
```

```asm
int f(int *a, int *b)
{
  
}
```

<!--stackedit_data:
eyJoaXN0b3J5IjpbNTAxNzkwNTMsMTk1MzA3NjYxOSw4MzEwOD
AwMiwtMTMwNzk0Mzc3OCwxODUwOTkwMjQ0LC02MDE2Njk2OTRd
fQ==
-->