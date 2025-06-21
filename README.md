# CAMAAR
Sistema para avaliação de atividades acadêmicas remotas do CIC

<h2>💻 Autores</h2>

<table>
  <tr>
    <td align="center"><a href="https://github.com/lucasdbr05" target="_blank"><img style="border-radius: 50%;" src="https://github.com/lucasdbr05.png" width="100px;" alt="Lucas Lima"/><br /><sub><b>Lucas Lima - 231003406</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/EmersonJr" target="_blank"><img style="border-radius: 50%;" src="https://github.com/EmersonJr.png" width="100px;" alt="Emerson Junior"/><br /><sub><b>Emerson Junior - 231003531</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/hsaless" target="_blank"><img style="border-radius: 50%;" src="https://github.com/hsaless.png" width="100px;" alt="Henrique Sales"/><br /><sub><b>Henrique Sales - 231034841</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/pedro-neris" target="_blank"><img style="border-radius: 50%;" src="https://github.com/pedro-neris.png" width="100px;" alt="Pedro Neris"/><br /><sub><b>Pedro Neris - 231018964</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/suzanassm" target="_blank"><img style="border-radius: 50%;" src="https://github.com/suzanassm.png" width="100px;" alt="Suzana Miranda"/><br /><sub><b>Suzana Miranda - 231037020</b></sub></a><br /></td>
</table>

<h2>👥 Funções no Projeto</h2>
<table>
    <tr>
        <th>Função</th>
        <th>Membro</th>
    </tr>
    <tr>
        <td>Scrum Master</td>
        <td>Lucas Lima - 231003406</td>
    </tr>
    <tr>
        <td>Product Owner</td>
        <td>Pedro Neris - 231018964</td>
    </tr>
</table>

<h2>🧭 Behavior Driven Design</h2>
<p>O projeto utiliza a abordagem de Behavior Driven Design (BDD) para descrever e organizar os comportamentos esperados do sistema. Para facilitar a visualização e o acompanhamento das features, utilizamos um quadro no Miro:</p>

<p><a href="https://miro.com/app/board/uXjVODb6Qw8=/" target="_blank">Quadro BDD no Miro</a> (https://miro.com/app/board/uXjVODb6Qw8=/)</p>

<ul>
  <li><strong>Amarelo</strong>: Feature (funcionalidade principal a ser implementada) - ao final da feature está o nome do responsável por fazer o BDD dela. As features são definidas pelas issues abertas do  repósitório <b>EngSWCiC/CAMAAR</b>, que podem ser encontradas também na pasta de <b>features</b> desse projeto, com cenários que seguem as regras de negócio definidas</li>
  <li><strong>Verde</strong>: Happy Path (fluxo principal de sucesso da feature)</li>
  <li><strong>Vermelho</strong>: Sad Path (fluxos alternativos ou de erro)</li>
  <li><strong>Azul</strong>: Spikes e dúvidas (pesquisas técnicas ou pontos que precisam de esclarecimento)</li>
</ul>


## Convenções:
### Mensagem de Commit
Deve ter seguinte formato {prefixo}+':'+{mensagem com verbo conjugado na 3º pessoa do presente do indicativo}. Ex.: `feat:adiciona implementação da função signIn`

- **feat:** Adiciona uma nova feature
- **fix:** Conserta bugs
- **refactor:** Refatora código sem mudar funcionalidade
- **test:** Adiciona ou altera testes
- **docs:** Adiciona ou altera documentação

### Nomes de Branches
Deve ter o seguinte foramto {prefixo} + '/' + {nome da branch em kebab case}. Os prefixos são os mesmo das mensagens de commit. Por exemplo:
`docs/corrige-documentacao-das-noticias`