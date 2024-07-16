window.addEventListener('message', function(event) {
    if (event.data.action === 'open') {
        document.getElementById('controlUI').style.display = 'block';
    } else if (event.data.action === 'close') {
        document.getElementById('controlUI').style.display = 'none';
    }
});

document.getElementById('upBtn').addEventListener('mousedown', function() {
    fetch(`https://${GetParentResourceName()}/moveLift`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ direction: 'up' })
    }).catch((error) => {
        console.error('Error:', error);
    });
});

document.getElementById('downBtn').addEventListener('mousedown', function() {
    fetch(`https://${GetParentResourceName()}/moveLift`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ direction: 'down' })
    }).catch((error) => {
        console.error('Error:', error);
    });
});

document.getElementById('closeBtn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).catch((error) => {
        console.error('Error:', error);
    });
});
