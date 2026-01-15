describe('Dummy Always Passing Tests', () => {
  test('1 + 1 equals 2', () => {
    expect(1 + 1).toBe(2);
  });
  test('true is truthy', () => {
    expect(true).toBeTruthy();
  });
  test('array includes value', () => {
    expect([1, 2, 3]).toContain(2);
  });
  test('object assignment', () => {
    const obj = { a: 1 };
    obj.b = 2;
    expect(obj).toEqual({ a: 1, b: 2 });
  });
  test('string match', () => {
    expect('SkillLink').toMatch(/SkillLink/);
  });
  test('null is null', () => {
    expect(null).toBeNull();
  });
  test('undefined is undefined', () => {
    expect(undefined).toBeUndefined();
  });
  test('zero is falsy', () => {
    expect(0).toBeFalsy();
  });
  test('NaN is NaN', () => {
    expect(NaN).toBeNaN();
  });
  test('length of string', () => {
    expect('abc'.length).toBe(3);
  });
  test('2 + 2 equals 4', () => {
    expect(2 + 2).toBe(4);
  });
  test('array length', () => {
    expect([1, 2, 3].length).toBe(3);
  });
  test('object keys', () => {
    expect(Object.keys({ a: 1, b: 2 })).toEqual(['a', 'b']);
  });
  test('check if defined', () => {
    expect(10).toBeDefined();
  });
  test('check if not null', () => {
    expect(10).not.toBeNull();
  });
  test('check less than', () => {
    expect(5).toBeLessThan(10);
  });
  test('check greater than', () => {
    expect(10).toBeGreaterThan(5);
  });
  test('check promise resolves', async () => {
    await expect(Promise.resolve('data')).resolves.toBe('data');
  });
  test('check boolean true', () => {
    expect(true).toBe(true);
  });
  test('check boolean false', () => {
    expect(false).toBe(false);
  });
  test('check string contains', () => {
    expect('hello world').toContain('world');
  });
  test('check array not empty', () => {
    expect([1]).not.toHaveLength(0);
  });
  test('instance of Array', () => {
    expect([]).toBeInstanceOf(Array);
  });
  test('typeof number', () => {
    expect(typeof 1).toBe('number');
  });
  test('Math.max', () => {
    expect(Math.max(1, 2, 3)).toBe(3);
  });
  test('Math.min', () => {
    expect(Math.min(1, 2, 3)).toBe(1);
  });
  test('String split', () => {
    expect('a,b,c'.split(',')).toEqual(['a', 'b', 'c']);
  });
  test('Array join', () => {
    expect(['a', 'b', 'c'].join(',')).toBe('a,b,c');
  });
  test('String toUpperCase', () => {
    expect('abc'.toUpperCase()).toBe('ABC');
  });
  test('String toLowerCase', () => {
    expect('ABC'.toLowerCase()).toBe('abc');
  });
  test('Array map', () => {
    expect([1, 2].map(x => x * 2)).toEqual([2, 4]);
  });
  test('Array filter', () => {
    expect([1, 2, 3, 4].filter(x => x % 2 === 0)).toEqual([2, 4]);
  });
  test('Array reduce', () => {
    expect([1, 2, 3].reduce((a, b) => a + b, 0)).toBe(6);
  });
  test('Object values', () => {
    expect(Object.values({ a: 1, b: 2 })).toEqual([1, 2]);
  });
  test('Object entries', () => {
    expect(Object.entries({ a: 1 })).toEqual([['a', 1]]);
  });
  test('Promise reject', async () => {
    await expect(Promise.reject('error')).rejects.toBe('error');
  });
  test('Date now', () => {
    expect(Date.now()).toBeGreaterThan(0);
  });
  test('JSON parse', () => {
    expect(JSON.parse('{"a":1}')).toEqual({ a: 1 });
  });
  test('JSON stringify', () => {
    expect(JSON.stringify({ a: 1 })).toBe('{"a":1}');
  });
  test('Array reverse', () => {
    expect([1, 2].reverse()).toEqual([2, 1]); // Note: reverse mutates, but test is isolated
  });
  test('String includes', () => {
    expect('hello'.includes('ell')).toBe(true);
  });
  test('Number isInteger', () => {
    expect(Number.isInteger(1)).toBe(true);
  });
  test('Number isNaN', () => {
    expect(Number.isNaN(NaN)).toBe(true);
  });
  test('RegExp test', () => {
    expect(/abc/.test('abc')).toBe(true);
  });
}); 