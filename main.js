var Heap = require('./ocaml/heap.bs.js');


function render (o, root) {
    var e = $('<div style="display:flex; flex-direction:horizontal">');
    root.append(e);
    o.forEach(function (tree, i) {
        var c = $('<div>').attr('id', 'HEAPTREE'+i);
        e.append(c);

        var width = 150*(tree.rank+1);
        c.css('width', ''+width+'px');
        c.css('height', '600px');

        new Treant({chart: {container: '#HEAPTREE'+i, 
                            nodeAlign: 'TOP'}, // not effective
                    nodeStructure: tree}); 

    });

}

function main () {
    var h = Heap.empty;
    var root = $('#heap');
    function rerender () {
        root.empty();
        var o = JSON.parse(Heap.json_of_heap(h));
        console.log('rerender', JSON.stringify(o));
        render(o, root);
    }

    rerender();

    $('#insert').click(function () {
        var input = $('#input-value');
        var v = Number(input.val());
        h = Heap.insert(v, h);
        input.val(v+1);
        rerender();
    });

    $('#deleteMin').click(function () {
        h = Heap.deleteMin(h);
        rerender();
    });
}

$(main);
