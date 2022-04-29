# Vigilância Cidadã de Veículos (VCV)

Este relatório detalha o projeto desenvolvido como trabalho final para a disciplina MPES0020 - Tópicos Avançados em Engenharia de Software II, ministrado pelo Prof. Dr. Frederico Lopes dentro do Programa de Pós-graduação em Engenharia de Software (PPgSW) na Universidade Federal do Rio Grande do Norte (UFRN).

Nele, propomos e desenvolvemos uma aplicação dentro do contexto de Cidades Inteligentes, seguindo os princípios apresentados e discutidos ao longo da disciplina, e apresentamos ao final um protótipo avançado dessa aplicação. Na sessão (ref) detalhamos essa proposta na sua forma final, e os desafios associados, assim como comparações a aplicações similares já existentes. Em seguida (sessão (ref)), é discutido o processo de desenvolvimento dessa aplicação, e as plataformas e tecnologias usadas. Finalmente (sessão (ref)), é descrito o protótipo na versão apresentada.

Propomos um projeto dentro do domínio de aplicações de segurança, tendo em mente os objetivos que normalmente acompanham projetos de cidades inteligentes: de melhorar a qualidade de vida na cidade, e de fazê-lo de modo sustentável.

A Vigilância Cidadã de Veículos (VCV) busca fazer isso engajando o cidadão no resgate de veículos furtados ou roubados, permitindo que qualquer pessoa possa, com o uso de um smartphone: capturar dinamicamente o número de uma placa a partir da câmera do celular; verificar se essa placa pertence a um veículo em situação não-regular; e se for o caso, enviar anonimamente a imagem capturada, assim como metadados de geolocalização e hora, para as autoridades apropriadas. Seria também fornecida a opção de relatar o furto ou roubo de um veículo, acrescendo a base de dados disponível.

Tendo isso em mente desenvolvemos um Business Model Canvas (ref), documentando todos os diferentes aspectos envolvidos no projeto. Diretamente da proposta inicial, temos certos valores consequentes. 

Primeiramente, uma maior facilidade em verificar a situação de um veículos, pela captura por imagens em tempo real, ao contrário de, por exemplo, preencher um formulário de consulta manualmente com a placa em questão. Também, uma denuncia prática e direta de veículos roubados, com informações exatas, poupando tempo e trabalho do cidadão preocupado, e de qualquer intermediário envolvido numa denúncia tradicional, como a que é feita atualmente por telefone. E, finalmente, o potencial de operações mais eficientes de recuperação de veículos pelas forças policiais.

Todos os valores mencionados beneficiam direta ou indiretamente o cidadão e o profissional de segurança pública, dado que sejam fornecidos de forma consistente e confiável. Tendo em vista a abrangência do segmento de clientes dessa aplicação, esperamos produzir um aplicativo multi-plataforma, que funcione no maior número de diferentes aparelhos móveis.

As parcerias chaves nesse projeto, que também representam o maior potencial de investimento, seriam órgãos públicos de segurança, em especial o Sistema Nacional de Informações de Segurança Pública (SINESP), já que os dados coletados só são efetivos ao chegaram nas autoridades apropriadas, e são a eles que os dados que essa aplicação pode vir a gerar mais beneficiariam. Baixos custos operacionais significam que a aplicação pode começar a ser usada como prova de conceito mesmo antes de qualquer parceria se solidificar.

Quanto a soluções já existentes, algumas realizam parcialmente nossa proposta, mas nenhuma por inteiro. Sivem Mobile, um aplicativo para Android, realiza reconhecimento dinâmico de placas pela câmera, e realiza um registro local da placa no aparelho, permitindo ao usuário que seja ativado um alarme ao reconhecer determinadas placas. Sinesp Cidadão, um aplicativo fornecido pelo SINESP, simplesmente informa a situação atual de um veículo, dado sua placa. Sinal, um sistema da Polícia Rodoviária Federal, recebe denúncias de veículos roubados pelo site oficial (prf.gov.br/sinal) ou pelo aplicativo Polícia Sinalize.

Além dessas, a solução existente que mais se aproxima da nossa proposta é um serviço oferecido através do aplicativo #EuFaçoPOA, da prefeitura de Porto Alegre, chamado Detetive Cidadão. Com ele, é possível reconhecer placas através de imagens, e enviar a imagem a autoridades locais. Porém, o reconhecimento não acontece em tempo real, apenas a partir de imagens estáticas, e deixa a desejar tanto em velocidade quanto acurácia. Além disso, o usuário não é informado da situação do veículo, e a solução é de escopo regional, voltada somente à segurança em Porto Alegre.

Desenvolvimento
Primeiramente, analisamos opções de visão computacional para reconhecimento de placas. Para evitar custos associados a reconhecimento por processamento remoto, limitamos nossa busca a soluções com processamento no próprio aparelho. 

Dentre essas, selecionamos o ML Kit da Google (antigo Mobile Vision), que fornece um modelo pré-treinado de reconhecimento de caracteres para uso em aplicações móveis, e em testes preliminares mostrou ter velocidade e acurácia mais do que satisfatórias. Para adaptar esse modelo para a nossa aplicação, seria somente necessário filtrar os conjuntos de caracteres reconhecidos para selecionar somente aqueles correspondentes com o padrão de uma placa veicular brasileira.

Para o desenvolvimento da aplicação em si, usamos Flutter: um framework open-source de desenvolvimento móvel, que compila código em Dart -- uma linguagem usada para aplicações web e móveis, similar a linguagens como Java, C#, e Javascript -- para código nativo para Android e iOS. Não apenas esse framework atendeu nossas necessidades multiplataforma, ela também se integra facilmente com o ML Kit e a base de dados usada (discutida a seguir), por serem todas criadas pela Google.

Nossos dados são a priori mantidos através da plataforma Firebase, por abstrair muitos processos de desenvolvimento back-end, e permitir rápida prototipagem, além, novamente de sua facilidade de integração. Além disso, para propósitos de prova de conceito, a carga permitida dentro do limite de uso grátis é mais do que o suficiente.

Em geral, ambos os desenvolvedores estavam envolvidos em todos os aspectos do desenvolvimento, especialmente por não terem experiência significativa com as tecnologias usadas. Inclusive, muito do processo se deu através da estratégia de pair programming, quando possível. Apesar de dificuldades iniciais, boa parte das metas foram atingidas dentro do prazo, como é apresentado a seguir.
