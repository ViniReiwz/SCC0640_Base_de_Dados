# Questão 1 - Resumo

A ideia da questão é criar as tabelas que compõem a base de dados.

Para criar uma tabela, usamos a tag `CREATE TABLE`.

Cada tabela terá alguns atributos, de tipos variados e com condições variáveis também.

## Tipos
Alguns dos tipos principais são:

- `INTEGER` ->> Número inteiro;
- `VARCHAR(X)` ->> "String" com tamanho X;
- `NUMERIC(X,Y)` ou `DECIMAL(X,Y)` ->> Número decimal com X algarismos, sendo Y após a vírgula e o restante na parte inteira;
- `TEXT` ->> Texto grande;
- `DATE` ->> Data ('ano-mes-dia');

Ainda, é possível criarmos o nosso próprio tipo de dados,
através de `CREATE TYPE`. Por exemplo, suponhamos que desejamos saber o nível de dificuldade de uma tarefa, que deve obrigatóriamente ser Fácil, Médio ou Difícil, podemos então fazer:

```sql

CREATE TYPE nivel_diff AS ENUM(
    'Fácil', 'Médio', 'Difícil'
);

```
Neste caso, criamos o tipo nivel_diff, que é um ENUM (ou seja, tem valores pré-estabelecidos).
Dessa forma, ao criar uma tabela, por exemplo:

```sql
    CREATE TABLE tarefa(
        ...,
        DIFICULDADE nìvel_diff,
        ...,
    );
```
O tipo `nivel_diff` faz com que, quando inserirmos nesta tabela, qualquer valor de dificuldade diferente de 'Fácil', 'Médio' ou 'Difícil' não poderá ser inserido (causará erro)

---
## Constraints
Cada condição variável de um atributo é chamado de `CONSTRAINT`.

Algumas constraints mais utilizadas
- `NOT NULL` ->> O atributo não pode ser nulo;
- `PRIMARY KEY` ->> Atributo atua com ochave primária;
- `UNIQUE` ->> Atributo não pode ter valor repetido dentro da tabela;
- `FOREIGN KEY` ->> Chave estrangeira (referencia um atributo em uma tabela externa);
- `CHECK( Cndições )` ->> Verifica se as condições são atendidas;

    ### Caso especial - ID
    Usualmente, quando queremos gerar o ID de alguma coisa (chave que identifica uma tupla univocamente na tabela), utilizamos o seguinte constraint:
    ```sql
        ATRIBUTO_ID INTEGER GENERATED ALWAYS AS IDENTITY,
        ...
    ```
    ou
    ```sql
        ATRIBUTO_ID INTEGER BY DEFAULT AS IDENTITY,
        ...
    ```

    Em ambos, não é necessário informar o ID para que este seja criado automáticamente ao inserir um dado na tabela atributo_id, mas `GENERATED ALWAYS` **não permite** que o ID seja atribuido manualmente, ou seja, a operação `INSERT INTO tabela (ATRIBUTO_ID,...) VALUES (Valor,...)` gera erro, enquanto no `BY DEFAULT` pode-se fazer essa atribuição.

Notemos ainda que as constraints podem ser adicionadas tanto a frente do atributo quanto depois na tabela, notemos no exemplo a seguir:
```sql
    CREATE TABLE PEDIDOS(
        PedidoID INTEGER GENERATED ALWAYS AS IDENTITY,
        ClienteID INTEGER NOT NULL,
        RestID INTEGER NOT NULL,
        DATA_PED DATE NOT NULL,
        STATUS_PED ped_status, -- Tipo criado como ENUM
        Valor NUMERIC(5,2),

        CONSTRAINT pedidos_pk PRIMARY KEY (PedidoID),
        CONSTRAINT pedidos_sk UNIQUE (ClienteID, RestID, DATA_PED),
        CONSTRAINT ped_fk_cli FOREIGN KEY (ClienteID) REFERENCES CLIENTES(ClienteID)
            ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT ped_fk_res FOREIGN KEY (RestID) REFERENCES RESTAURANTES(RestauranteID)
            ON DELETE CASCADE ON UPDATE CASCADE
    );
```
> `NOT NULL` sempre deve ser posto na frente do atributo, mas o restante pode adicionar como constraint.

Perceba ainda o comportamento da foreign key: `FOREIGN KEY (X) REFERENCES A(Y)`, onde o **X** representa o atributo na tabela atual, e **Y** representa o atributo referenciado na tabela **A**.
Temos também o comportamento mediante `DELETE` e `UPDATE`
- `CASCADE` ->> Se a linha em **A** com a chave referenciada sofrer um `DELETE/UPDATE`, a linha na tabela atual também sofrerá a mesma operação
- `RESTRICT` ->> Impossibilita alterações na tabela referenciada (**A**) se existirem dependências na tabela atual.

> PS: Ainda, é possível adicionar/remover constraints após a criação da tabela com o uso de ALTER TABLE ->> `ALTER TABLE nome_tabela ADD CONSTRAINT nome_variavel CONSTRAINT DESEJADA;` (para remover, substitua `ADD` por `DROP`);
> Se for NOT NULL tem que ser `ALTER table Nome_tab ALTER COLUMN atributo_nome SET NOT NULL;`

Por fim, podemos ter o domain:
```sql
    CREATE DOMAIN nome_domain TIPO_DO_ATRIBUTO
        CHECK( Condições );
```

Que atua basicamete como um tipo de dados que possui condições, como por exemplo:
```sql
    CREATE DOMAIN valor_positivo INTEGER
        CHECK (VALUE > 0);
```

Agora, para todo o atributo que tiver o tipo positivo, ele será um inteiro e a verificação de o valor a ser inserida na coluna ser maior do que 0 será feita automáticamente, bastando apenas `Atributo valor_positivo,` para aplicar as condições.

Par ver implementação, clique [aqui](./Questão1-db_definition-resume.sql).