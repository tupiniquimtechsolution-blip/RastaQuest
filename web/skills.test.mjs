import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => JSON.parse(readFileSync(new URL(path, import.meta.url), 'utf8'));
const tree = read('./data/skills.json');
const canonical = read('../assets/production_drafts/2026-10-24/skill-tree-v02/SKILL_TREE_DESIGN.json');

test('mirrored skill tree is identical to approved v02 design proposal', () => {
  assert.deepEqual(tree, canonical);
  assert.equal(tree.version, 2);
  assert.equal(tree.costs, null);
  assert.equal(tree.numerical_balance, null);
});

test('skill tree has exactly 25 unique nodes in five branches and valid dependencies', () => {
  assert.equal(tree.branches.length, 5);
  const all = tree.branches.flatMap(b => b.nodes);
  assert.equal(all.length, 25);
  assert.equal(new Set(all.map(n => n.id)).size, 25);
  const IDs = new Set(all.map(n => n.id).concat([tree.root.id]));
  for(const node of all) {
    assert.ok(node.requires.every(id => IDs.has(id)), node.id);
    assert.ok(node.tier >= 1 && node.tier <= 5);
    assert.equal(node.cost, null);
  }
  for (const branch of tree.branches) {
    assert.equal(branch.nodes.length, 5);
    assert.equal(branch.nodes.filter(n => n.capstone).length, 1);
  }
});

test('UI remains explicitly read-only until the numerical balancing gate', () => {
  const html = readFileSync(new URL('./index.html', import.meta.url), 'utf8');
  assert.match(html, /id="skillTree"/);
  assert.match(html, /Custos e efeitos ainda não estão aprovados/);
});
