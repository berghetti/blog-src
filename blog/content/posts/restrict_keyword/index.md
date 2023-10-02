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
int
g( int  *restrict a,  int  *restrict b)
// f ( int  *a,  int  *b)
{
  *a =  1;
  *b =  2;
  return  *a;
}
```

Veja um exemplo do código gerado para as funções `f` e `g` acima.
A unica diferença entre elas é a assinatura da função.

```asm
f:
  mov  DWORD  PTR  [rdi], 1   ; *a = 1
  mov  DWORD  PTR  [rsi], 2   ; *b = 2
  mov  eax, DWORD  PTR  [rdi] ; return *a
  ret

g:
  mov  DWORD  PTR  [rdi], 1 ; *a = 1
  mov  eax, 1               ; return 1;
  mov  DWORD  PTR  [rsi], 2 ; *b = 2
  ret
```

