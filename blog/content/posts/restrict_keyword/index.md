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

## Entendendo o uso.

O qualificador *restrict* diz ao compilador que um ponteiro não tem um *aliasing*, ou seja, não existe outro ponteiro que modifique o objeto. Por exemplo, uma função que possui a assinatura `int f(int *a, int *b)`, os ponteiros `a` e `b` podem apontar para o mesmo objeto. O compilador tem que levar isso em consideração ao gerar o código.

Se sabemos que os ponteiros não apontam para o mesmo objeto, dizemos isso ao compilador usando a palavra-chave *restrict*.  Isso permite que o código possa ser melhor otimizado.
Por exemplo, tome as funções `f` e `g`abaixo. A única diferença entre elas é a assinatura.

```c
int
// f ( int  *a,  int  *b)
g( int  *restrict a,  int  *restrict b)
{
  *a =  1;
  *b =  2;
  return  *a;
}
```
Veja o código gerado, com GCC, abaixo. 
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
Na função `f`, temos três acessos à memória. Isso ocorre porque quando atualizamos o valor de `*b`, o compilador não tem garantia de que o objeto `*a` não foi modificado. Assim, para retornar o valor de `*a`, um novo acesso à memória é feito ao invés de, apenas, preservar o valor previamente atribuído.
A função `g`, devido a não precisar carregar novamente o valor de `*a`, possui um acesso à memória a menos. Aqui o compilador pode assumir que o valor de `*a`não é alterado após a atribuição inicial.

## strict aliasing

O GCC possui a opção `strictest aliasing`
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTE0MDc1MTE5NSwtMjM3NDE4MjMyLDE3OD
Q3OTEyMzMsLTUyMzk2NTUwMywtMjAyNzg3ODY2NSwtNDg4MDg4
MzA1LDY2ODMwNDE1NiwtMTczNzcyMTY0LDE1MDEzNDI3OV19
-->