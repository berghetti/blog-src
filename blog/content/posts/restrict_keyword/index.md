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

## Entendendo o uso

O qualificador *restrict* diz ao compilador que um ponteiro não tem um *aliasing*, ou seja, não existe outro ponteiro que modifique o objeto [^1]. Por exemplo, uma função que possui a assinatura `int f(int *a, int *b)`, os ponteiros `a` e `b` podem apontar para o mesmo objeto. O compilador tem que levar isso em consideração ao gerar o código.

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

## Strict aliasing

O compilador GCC possui a opção `-fstrictest aliasing`, habilitada nos níveis de otimização`-O2`,` -O3` e `-Os`[^2].  Com essa opção, o compilador segue uma regra que diz, **ponteiros de tipos diferentes não apontam para o mesmo objeto**. A exceção a regra são ponteiros do tipo `char`, que podem ser *aliases* para qualquer tipo.

Caso a função `f`, apresentada acima, fosse implementada com a assinatura `long f(long *a, int *b)`, ou seja, ponteiros para tipos diferentes, e compilada com a opção `-fstrictest aliasing`, teríamos o mesmo efeito de usar o modificador *restrict*. O compilador assumirá, nesse caso, que os ponteiros não apontam para o mesmo objeto e irá otimizar o código.

## Conclusão

Caso tenha uma função que tenha mais de 1 ponteiro do mesmo tipo em seus parâmetros, ou que tenha mais de 1 ponteiro e algum deles é do tipo `char`, use o modificador *restrict* para habilitar melhor otimização no código. Claro, contanto que os ponteiros não apontem para o mesmo lugar. Utilizar um nível de otimização de, pelo menos, `-O2`. Para habilitar a regra de *aliasing* automaticamente para ponteiros de tipos diferentes.

[^1]: https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf, section 6.7.3.7
[^2]: https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html#index-fstrict-aliasing
<!--stackedit_data:
eyJwcm9wZXJ0aWVzIjoiZXh0ZW5zaW9uczpcbiAgcHJlc2V0Oi
Bjb21tb25tYXJrXG4iLCJoaXN0b3J5IjpbMjA4ODYyMjY3OCwy
MDg4NjIyNjc4LDE2MzY5OTMxNzEsMTI0MjM1OTQ2NSwtMTk1OT
c1NjAwMiwtMjAyNDc0MTQ2NiwtMTQ1MDg5MDIyMSwyODg0NTk5
MTMsLTIzNzQxODIzMiwxNzg0NzkxMjMzLC01MjM5NjU1MDMsLT
IwMjc4Nzg2NjUsLTQ4ODA4ODMwNSw2NjgzMDQxNTYsLTE3Mzc3
MjE2NCwxNTAxMzQyNzldfQ==
-->