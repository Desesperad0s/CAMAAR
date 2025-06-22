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
  <li><strong>Amarelo</strong>: Feature (funcionalidade principal a ser implementada) - ao final da feature está o nome do responsável por fazer o BDD dela e com uma estimativa de pontos dados para a dificuldade da tarefa (definido em conjunto). As features são definidas pelas issues abertas do  repósitório <b>EngSWCiC/CAMAAR</b>, que podem ser encontradas também na pasta de <b>features</b> desse projeto, com cenários que seguem as regras de negócio definidas e presentes nas histórias de usuário</li>
  <li><strong>Verde</strong>: Happy Path (fluxo principal de sucesso da feature)</li>
  <li><strong>Vermelho</strong>: Sad Path (fluxos alternativos ou de erro)</li>
  <li><strong>Azul</strong>: Spikes e dúvidas (pesquisas técnicas ou pontos que precisam de esclarecimento)</li>
</ul>

<h2> Features e pontos atribuídas para cada uma </h2>
  <li> Admin criar template para formulários - pontos: 3 </li>
  <li> Usuário (participante de uma turma) responder questionário da turma - pontos: 2 </li>
  <li> Admin criar formulário a partir de um template para as turmas que escolher - pontos: 2 </li>
  <li> Admin criar formulário a partir de um template para alunos ou professores (bônus) - pontos: 2 </li>
  <li> Admin exportar resultados de formulário - pontos: 5 </li>
  <li> Admin editar e deletar templates criados - pontos: 5 </li>
  <li> Admin importar dados do SIGAA - pontos: 2 </li>
  <li> Usuário fazer login no sistema - pontos: 2 </li>
  <li> Admin gerenciar turmas do departamento que pertence (bônus) - pontos: 1 </li>
  <li> Usuário definir senha no primeiro acesso via e-mail de cadastro - pontos: 3 </li>
  <li> Usuário redefinir senha a partir do e-mail (bônus) - pontos: 3 </li>
  <li> Administrador cadastrar participantes de turmas do SIGAA - pontos: 3 </li>
  <li> Administrador gerenciar templates criados - pontos: 2 </li>
  <li> Admin atualizar base de dados já existente com os dados atuais do SIGAA - pontos: 2 </li>
  <li> Usuário (participante de uma turma) deve ver os formulários não respondidos das turmas que está matriculado - pontos: 2</li>
  <li> Admin ver os formulários criados e gerar relatório das respostas - pontos: 5</li>
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
