/** 25-node topology copied from canonical skill-tree-v02 for working web study.
 * Prices and numeric effects are PROTOTYPE ONLY; source canon specified null costs. */
export const SKILL_TREE = Object.freeze({
  "version": 1,
  "title": "Raízes do Trovão",
  "source": "assets/production_drafts/2026-10-24/skill-tree-v02/SKILL_TREE_DESIGN.json",
  "status": "PROTOTYPE_BALANCE_REQUIRES_REVIEW",
  "root": "raiz_ancestral",
  "branches": [
    {
      "id": "vigor",
      "title": "Vigor Ancestral",
      "nodes": [
        {
          "id": "vigor_1",
          "name": "Raízes Vivas",
          "tier": 1,
          "requires": [
            "raiz_ancestral"
          ],
          "capstone": false,
          "cost": 12
        },
        {
          "id": "vigor_2",
          "name": "Fôlego Ancestral",
          "tier": 2,
          "requires": [
            "vigor_1"
          ],
          "capstone": false,
          "cost": 25
        },
        {
          "id": "vigor_3",
          "name": "Corpo Firme",
          "tier": 3,
          "requires": [
            "vigor_2"
          ],
          "capstone": false,
          "cost": 44
        },
        {
          "id": "vigor_4",
          "name": "Coração da Terra",
          "tier": 4,
          "requires": [
            "vigor_3"
          ],
          "capstone": false,
          "cost": 69
        },
        {
          "id": "vigor_5",
          "name": "Vigor Pleno",
          "tier": 5,
          "requires": [
            "vigor_4"
          ],
          "capstone": true,
          "cost": 100
        }
      ]
    },
    {
      "id": "tecnicas",
      "title": "Técnicas de Combate",
      "nodes": [
        {
          "id": "tecnicas_1",
          "name": "Corte Ascendente",
          "tier": 1,
          "requires": [
            "raiz_ancestral"
          ],
          "capstone": false,
          "cost": 12
        },
        {
          "id": "tecnicas_2",
          "name": "Varredura Baixa",
          "tier": 2,
          "requires": [
            "tecnicas_1"
          ],
          "capstone": false,
          "cost": 25
        },
        {
          "id": "tecnicas_3",
          "name": "Quebra de Guarda",
          "tier": 3,
          "requires": [
            "tecnicas_2"
          ],
          "capstone": false,
          "cost": 44
        },
        {
          "id": "tecnicas_4",
          "name": "Rebatida Precisa",
          "tier": 4,
          "requires": [
            "tecnicas_3"
          ],
          "capstone": false,
          "cost": 69
        },
        {
          "id": "tecnicas_5",
          "name": "Sequência Ancestral",
          "tier": 5,
          "requires": [
            "tecnicas_4"
          ],
          "capstone": true,
          "cost": 100
        }
      ]
    },
    {
      "id": "movimento",
      "title": "Movimento do Guerreiro",
      "nodes": [
        {
          "id": "movimento_1",
          "name": "Passo Leve",
          "tier": 1,
          "requires": [
            "raiz_ancestral"
          ],
          "capstone": false,
          "cost": 12
        },
        {
          "id": "movimento_2",
          "name": "Salto Preciso",
          "tier": 2,
          "requires": [
            "movimento_1"
          ],
          "capstone": false,
          "cost": 25
        },
        {
          "id": "movimento_3",
          "name": "Avanço Ágil",
          "tier": 3,
          "requires": [
            "movimento_2"
          ],
          "capstone": false,
          "cost": 44
        },
        {
          "id": "movimento_4",
          "name": "Travessia Fluida",
          "tier": 4,
          "requires": [
            "movimento_3"
          ],
          "capstone": false,
          "cost": 69
        },
        {
          "id": "movimento_5",
          "name": "Liberdade de Movimento",
          "tier": 5,
          "requires": [
            "movimento_4"
          ],
          "capstone": true,
          "cost": 100
        }
      ]
    },
    {
      "id": "defesa",
      "title": "Defesa e Equilíbrio",
      "nodes": [
        {
          "id": "defesa_1",
          "name": "Guarda Firme",
          "tier": 1,
          "requires": [
            "raiz_ancestral"
          ],
          "capstone": false,
          "cost": 12
        },
        {
          "id": "defesa_2",
          "name": "Defesa Precisa",
          "tier": 2,
          "requires": [
            "defesa_1"
          ],
          "capstone": false,
          "cost": 25
        },
        {
          "id": "defesa_3",
          "name": "Escudo do Trovão",
          "tier": 3,
          "requires": [
            "defesa_2"
          ],
          "capstone": false,
          "cost": 44
        },
        {
          "id": "defesa_4",
          "name": "Retorno de Energia",
          "tier": 4,
          "requires": [
            "defesa_3"
          ],
          "capstone": false,
          "cost": 69
        },
        {
          "id": "defesa_5",
          "name": "Guardião do Equilíbrio",
          "tier": 5,
          "requires": [
            "defesa_4"
          ],
          "capstone": true,
          "cost": 100
        }
      ]
    },
    {
      "id": "tempestade",
      "title": "Poder da Tempestade",
      "nodes": [
        {
          "id": "tempestade_1",
          "name": "Centelha",
          "tier": 1,
          "requires": [
            "raiz_ancestral"
          ],
          "capstone": false,
          "cost": 12
        },
        {
          "id": "tempestade_2",
          "name": "Elo Elétrico",
          "tier": 2,
          "requires": [
            "tempestade_1"
          ],
          "capstone": false,
          "cost": 25
        },
        {
          "id": "tempestade_3",
          "name": "Onda do Trovão",
          "tier": 3,
          "requires": [
            "tempestade_2"
          ],
          "capstone": false,
          "cost": 44
        },
        {
          "id": "tempestade_4",
          "name": "Fúria da Tempestade",
          "tier": 4,
          "requires": [
            "tempestade_3"
          ],
          "capstone": false,
          "cost": 69
        },
        {
          "id": "tempestade_5",
          "name": "Maestria Ancestral",
          "tier": 5,
          "requires": [
            "tempestade_4"
          ],
          "capstone": true,
          "cost": 100
        }
      ]
    }
  ]
});
const nodes=SKILL_TREE.branches.flatMap(b=>b.nodes);
export const SKILL_NODES=Object.freeze(Object.fromEntries(nodes.map(n=>[n.id,n])));

export function sanitizeSkills(candidate) {
  if(!Array.isArray(candidate)) return [];
  const requested=new Set(candidate.filter(id=>typeof id==='string' && SKILL_NODES[id]));
  const valid=new Set([SKILL_TREE.root]);
  for(let tier=1;tier<=5;tier++) {
    for(const node of nodes.filter(n=>n.tier===tier)) {
      if(requested.has(node.id) && node.requires.every(id=>valid.has(id))) valid.add(node.id);
    }
  }
  valid.delete(SKILL_TREE.root);
  return [...valid].sort();
}

export function canPurchaseSkill(profile,id) {
  const node=SKILL_NODES[id];
  return Boolean(node && !profile.skills.includes(id) &&
    node.requires.every(req=>req===SKILL_TREE.root || profile.skills.includes(req)) &&
    profile.essence>=node.cost);
}

export function purchaseSkill(profile,id) {
  if(!canPurchaseSkill(profile,id)) return false;
  profile.essence-=SKILL_NODES[id].cost;
  profile.skills.push(id);profile.skills.sort();
  return true;
}

export function branchLevel(profile,id) {
  return (profile?.skills ?? []).filter(s=>s.startsWith(id+'_')).length;
}

export function skillBonus(profile,stat) {
  switch(stat) {
    case 'vitality': return branchLevel(profile,'vigor');
    case 'damage': return Math.floor(branchLevel(profile,'tecnicas')/2);
    case 'mobility': return branchLevel(profile,'movimento')*12;
    case 'jump': return branchLevel(profile,'movimento')*9;
    case 'mana': return Math.floor(branchLevel(profile,'tempestade')/2);
    case 'special': return Math.floor(branchLevel(profile,'tempestade')/2);
    case 'defense': return branchLevel(profile,'defesa');
    default: return 0;
  }
}
