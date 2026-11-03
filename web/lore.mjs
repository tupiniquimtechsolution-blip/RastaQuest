/** Lore de fantasia ORIGINAL, para revisão cultural e narrativa antes de publicar.
 * Estes trechos não representam ritos, tradições ou afirmações religiosas oficiais.
 * As 21 memórias correspondem às salas do catálogo canônico; são colecionáveis permanentes.
 */
export const LORE = Object.freeze({
  "forest-01": {
    "id": "forest-01",
    "title": "A estrada de Rasta",
    "body": "Na orla da Floresta Corrompida, o viajante que todos chamam de Rasta ouve um nome antigo entre as árvores. Seu caminho não começa com uma profecia: começa com a escolha de ajudar os esquecidos."
  },
  "forest-02": {
    "id": "forest-02",
    "title": "As raízes do silêncio",
    "body": "Pontes antigas apodrecem sob uma força que apaga nomes e lembranças. Akane percebe que vencer um inimigo não basta quando a floresta ainda precisa ser ouvida."
  },
  "forest-03": {
    "id": "forest-03",
    "title": "A voz do caçador",
    "body": "Nas trilhas marcadas pela presença de Oxóssi, a floresta ensina atenção e respeito ao que não se vê. Os vigias corrompidos guardam um segredo que já não compreendem."
  },
  "forest-04": {
    "id": "forest-04",
    "title": "Cachoeira das memórias",
    "body": "A água transporta ecos de caminhos interrompidos. Atrás da cascata, um fragmento da história fala de um machado que se revela àquele que aceita a responsabilidade de empunhá-lo."
  },
  "forest-05": {
    "id": "forest-05",
    "title": "Ferro e caminho",
    "body": "A passagem de uma antiga forja remete a Ogum e ao trabalho de transformar matéria em instrumento. Akane aprende que cada peça encontrada pode abrir caminhos sem substituir suas escolhas."
  },
  "forest-06": {
    "id": "forest-06",
    "title": "O nome sob a árvore",
    "body": "A árvore não chama o viajante de Rasta. Em seus anéis resiste o nome Akane Xangô, associado ao compromisso com o equilíbrio e à coragem de julgar os próprios atos."
  },
  "forest-07": {
    "id": "forest-07",
    "title": "O julgamento da raiz",
    "body": "Ao purificar o guardião, Akane não abre um portal com o machado: um marco ancestral desperta porque a corrupção cedeu. O destino seguinte espera entre pedras fraturadas."
  },
  "castle-01": {
    "id": "castle-01",
    "title": "O portão dos esquecidos",
    "body": "O Castelo Fraturado recebeu promessas de proteção. Agora seus portões guardam apenas ordens vazias e cavaleiros que confundem obediência com justiça."
  },
  "castle-02": {
    "id": "castle-02",
    "title": "Correntes partidas",
    "body": "Cada corrente suspensa mantém uma passagem sobre o abismo. Akane descobre que liberdade exige destreza e que nenhuma armadura pode substituir a vontade de seguir."
  },
  "castle-03": {
    "id": "castle-03",
    "title": "A lâmina e a voz",
    "body": "Nos arcos caídos, um registro descreve um guerreiro chamado Akane. A história contradiz os rumores: o machado foi encontrado, não herdado como privilégio."
  },
  "castle-04": {
    "id": "castle-04",
    "title": "O sino rachado",
    "body": "O sino que anunciava segurança toca agora apenas diante de ameaças. O vento recorda a presença de Iansã, imagem de movimento e mudança nesta fantasia original."
  },
  "castle-05": {
    "id": "castle-05",
    "title": "O coração da forja",
    "body": "As mãos que moldaram as peças da fortaleza sabiam que todo metal guarda escolhas. O ferro não comanda Akane; permite que ele se prepare melhor para a próxima jornada."
  },
  "castle-06": {
    "id": "castle-06",
    "title": "O arquivo proibido",
    "body": "Entre páginas partidas, Akane encontra a origem de um pacto que alimentou a fratura. Os senhores do castelo tentaram aprisionar o eco do mundo para possuir suas passagens."
  },
  "castle-07": {
    "id": "castle-07",
    "title": "O juramento quebrado",
    "body": "A vitória sobre o guardião devolve voz às muralhas. A passagem às cavernas surge de mecanismos antigos reunidos, enquanto o machado continua símbolo e arma, nunca chave de portais."
  },
  "caves-01": {
    "id": "caves-01",
    "title": "A boca dos ecos",
    "body": "Nas Cavernas dos Ecos, passos do presente encontram respostas de um passado não resolvido. A pedra devolve perguntas que Akane havia evitado."
  },
  "caves-02": {
    "id": "caves-02",
    "title": "Os nomes gravados",
    "body": "Pedras luminosas revelam nomes de pessoas que resistiram à ruptura. A coleção de memórias oferece mais que força: mostra o custo de abandonar a verdade."
  },
  "caves-03": {
    "id": "caves-03",
    "title": "Água sob a pedra",
    "body": "No silêncio de uma nascente protegida, Akane percebe que descansar também pode ser um ato de coragem. A jornada avança sem transformar referências aos orixás em cópias de ritos."
  },
  "caves-04": {
    "id": "caves-04",
    "title": "A câmara do trovão",
    "body": "O machado vibra com a energia que Akane aprendeu a conduzir. Sua força deriva de escolhas, treino e memória; o estrondo não decide sozinho o que é justo."
  },
  "caves-05": {
    "id": "caves-05",
    "title": "O reflexo da queda",
    "body": "Uma ponte mineral fragmentada faz Akane encarar o retorno após a morte. No Santuário Ancestral, cada queda se transforma em preparação, não no apagamento de toda a experiência."
  },
  "caves-06": {
    "id": "caves-06",
    "title": "Antes do último eco",
    "body": "Fragmentos dos três mundos se encontram numa mesma fissura. O viajante reconhece que o nome Akane Xangô não encerra sua história: torna sua responsabilidade mais nítida."
  },
  "caves-07": {
    "id": "caves-07",
    "title": "O eco que permanece",
    "body": "Diante do último guardião, Akane escolhe restaurar o vínculo entre os mundos. A justiça não é vingança, e a memória dos caminhos percorridos seguirá viva em novas jornadas."
  }
});
export function validLoreIds(input){
  if(!Array.isArray(input))return [];
  return [...new Set(input.filter(id=>typeof id==='string' && LORE[id]))].sort();
}
