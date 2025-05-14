Language: [English](https://github.com/slackjeff/dd_best_bs/blob/main/README.md)

# dd Best bs
===

`dd_best_bs` é um script de teste de desempenho de blocos com `dd`.

`dd_best_bs` mede o desempenho de escrita em disco com diferentes tamanhos de bloco, utilizando o comando `dd`. Ele permite identificar o tamanho de bloco que oferece **a melhor taxa de transferência** e destaca o resultado mais eficiente.

## 📌 Como funciona?

1. Testa múltiplos tamanhos de bloco de **512B a 64MB**.
2. Usa o comando `dd` para gerar arquivos temporários e medir a velocidade de escrita.
3. Opcionalmente, **limpa o cache do kernel** se executado como `sudo`, garantindo resultados mais precisos.
4. Exibe uma tabela com os resultados de cada teste.
5. Ao final, **destaca o bloco com maior taxa de transferência**.


## 📦 Requisitos

- **Sistema Linux** ou macOS (compatível com `dd`).
- Acesso a um terminal.
- (Opcional) **Permissões root** para limpar o cache do kernel.

## 🔧 Como usar?

**Baixe ou copie o script:**

```shell
wget https://github.com/slackjeff/dd_best_bs/blob/main/dd_best_bs.sh
chmod +x dd_best_bs.sh
sudo ./dd_best_bs.sh
```

## Licença

O projeto está disponível como código aberto sob os termos do
[MIT License](https://github.com/slackjeff/dd_best_bs/blob/main/LICENSE) ©