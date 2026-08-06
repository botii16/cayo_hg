const hudRoot = document.getElementById('hg-hud');
const zoneTimer = document.getElementById('hg-zone-timer');
const lootTimer = document.getElementById('hg-loot-timer');
const zoneIndexEl = document.getElementById('hg-zone-index');

function formatSeconds(sec) {
    sec = Math.max(0, Math.floor(sec));
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}:${s < 10 ? '0' + s : s}`;
}

window.addEventListener('message', (event) => {
    const data = event.data;
    switch (data.action) {
        case 'hudShow':
            hudRoot.classList.remove('hidden');
            break;
        case 'hudHide':
            hudRoot.classList.add('hidden');
            break;
        case 'hudUpdate':
            if (typeof data.zoneRemaining === 'number') {
                zoneTimer.textContent = formatSeconds(data.zoneRemaining);
            }
            if (typeof data.lootRemaining === 'number') {
                lootTimer.textContent = formatSeconds(data.lootRemaining);
            }
            if (typeof data.zoneIndex === 'number' && Array.isArray(data.totalStages)) {
                zoneIndexEl.textContent = `${data.zoneIndex} / ${data.totalStages.length}`;
            }
            break;
    }
});