// ============================================================
// SAPPHIRE+ SHOWCASE APP LOGIC
// Easy Devlog & Features Management
// ============================================================

// ==========================================
// 1. DEVLOG / CHANGELOG DATA (EDIT HERE TO ADD UPDATES)
// ==========================================
const devlogs = [
    {
        version: "v0.5.0",
        isLatest: true,
        tag: "Stealth & Pre-Planning Update",
        items: [
            { label: "Multi-Pickup", desc: "Pick up multiple keycards, planks, C4, and thermite with accurate HUD quantity badges. Solo Shadow Raid vault is now fully accessible." },
            { label: "Infinite Camera Loop", desc: "Extended tape loop duration to 99,999 seconds with full Extra Heist Info (EHI) timer synchronization." },
            { label: "Minimum Detection Risk", desc: "Forces 3 Detection Risk (minimum suspicion offset) regardless of equipped armor (ICTV) or heavy weapons." },
            { label: "Unlimited Pre-Planning Favors", desc: "Removed favor budget limits and eliminated asset favor and offshore cash costs." },
            { label: "Single-Page Menu Overhaul", desc: "Reorganized Mod Options into a clean, priority-sorted single page without sub-menus." }
        ]
    },
    {
        version: "v0.4.0",
        isLatest: false,
        tag: "Carry, Stealth & QoL Expansion",
        items: [
            { label: "Carry Overhaul", desc: "Added sprint-with-carry, jump height normalization, and eliminated movement speed penalties on heavy loot bags and body bags." },
            { label: "Bag Throw Distance", desc: "Added customizable slider (1.0x - 5.0x) for extended loot bag tossing." },
            { label: "Stealth & Pagers", desc: "Added AI Can't Alarm, Auto-Answer Pagers, and configurable Random Pagers removal chance slider." },
            { label: "Interactions", desc: "Added extended interaction distance multiplier (up to 5x) and instant interaction / no cooldown toggle." },
            { label: "Survivability", desc: "Added No Fall Damage, Bag Damage Absorption, and Armor Movement Penalty bypass." },
            { label: "DLC Unlocks", desc: "Enabled free hosting for all DLC heists directly from Crime.net." },
            { label: "Smart Safe Mode", desc: "Automatically neutralizes cheat-tier features when joining other players' multiplayer lobbies." }
        ]
    },
    {
        version: "v0.1.0",
        isLatest: false,
        tag: "Initial Release",
        items: [
            { label: "Core Mod Framework", desc: "Core SuperBLT hook architecture, JSON configuration persistence, in-game hotkey toggle, and basic bag movement modifications." }
        ]
    }
];

// ==========================================
// 2. COMPLETE FEATURE MODULES DATA
// ==========================================
const features = [
    // --- STEALTH TOOLS ---
    {
        title: "Multi-Pickup (Keycards & Consumables)",
        category: "stealth",
        tag: "Stealth",
        icon: "key-round",
        desc: "Stack consumable mission items including Keycards, Planks, C4, and Thermite without hitting inventory limits. Essential for solo stealth on maps like Shadow Raid vault."
    },
    {
        title: "Infinite Camera Loop",
        category: "stealth",
        tag: "Stealth",
        icon: "cctv",
        desc: "Extends tape loop duration to 99,999 seconds. Fully synced with Extra Heist Info (EHI) and HUD timer overlays. Loop a camera once and ignore it for the rest of the heist."
    },
    {
        title: "Minimum Detection Risk (Always 3)",
        category: "stealth",
        tag: "Stealth",
        icon: "shield-alert",
        desc: "Forces detection risk to the engine minimum (3 Detection Risk) regardless of what heavy armor (ICTV) or weapons you wear. Grants maximum Sneaky Bastard & Low Blow bonuses."
    },
    {
        title: "AI Can't Alarm",
        category: "stealth",
        tag: "Stealth",
        icon: "bell-off",
        desc: "Prevents guards, civilians, and cops from raising the alarm, shooting panic flares, or triggering emergency calls."
    },
    {
        title: "Random Pagers / No Pager Chance",
        category: "stealth",
        tag: "Stealth",
        icon: "radio",
        desc: "Configurable slider (1% - 100%) that gives a random chance for eliminated security guards to drop no pager at all, preserving your 4-pager limit."
    },
    {
        title: "Auto-Answer Pagers",
        category: "stealth",
        tag: "Stealth",
        icon: "phone-call",
        desc: "Automatically answers pagers immediately when a security guard is neutralized, preventing missed pagers while managing stealth objectives."
    },

    // --- CARRY & MOVEMENT ---
    {
        title: "Carry Weight & Sprint Overhaul",
        category: "carry",
        tag: "Carry",
        icon: "zap",
        desc: "Sprint at full speed while carrying gold, artifacts, or nuclear warheads. Completely removes the vanilla sluggish walk/sprint penalties on heavy bags."
    },
    {
        title: "Bag Throw Distance Multiplier",
        category: "carry",
        tag: "Carry",
        icon: "arrow-up-right",
        desc: "Customizable slider (1.0x to 5.0x) to fling loot bags over rooftops, across broad courtyards, or directly into escape vehicles from afar."
    },
    {
        title: "Jump Height with Heavy Bags",
        category: "carry",
        tag: "Carry",
        icon: "chevrons-up",
        desc: "Maintains full jumping height while carrying any loot type, allowing you to vault over fences, windows, and obstacles effortlessly."
    },
    {
        title: "Affect Body Bags",
        category: "carry",
        tag: "Carry",
        icon: "user-x",
        desc: "Applies all sprint, jump, and movement speed multipliers to civilian and security guard body bags as well."
    },
    {
        title: "Ignore Armor Movement Penalty",
        category: "carry",
        tag: "Movement",
        icon: "shield",
        desc: "Eliminates movement speed, stamina drain, and agility penalties when wearing heavy ballistic vests and the Improved Combined Tactical Vest (ICTV)."
    },
    {
        title: "No Fall Damage",
        category: "carry",
        tag: "Movement",
        icon: "activity",
        desc: "Eliminates all fall damage when jumping from roofs, crane platforms, or balconies while securing loot bags."
    },
    {
        title: "Bag Damage Absorption",
        category: "carry",
        tag: "Carry",
        icon: "shield-plus",
        desc: "Grants customizable damage resistance (up to 100%) while carrying loot bags, giving you extra survivability during intense extractions."
    },
    {
        title: "Infinite Stamina",
        category: "carry",
        tag: "Movement",
        icon: "gauge",
        desc: "Sprint indefinitely without your stamina meter depleting or your character running out of breath."
    },

    // --- QUALITY OF LIFE & PRE-PLANNING ---
    {
        title: "Unlimited Pre-Planning Favors",
        category: "qol",
        tag: "Pre-Planning",
        icon: "wallet",
        desc: "Removes pre-planning favor budget limits and reduces favor and offshore cash costs to $0. Purchase every camera feed, spycam, dead drop, and escape plan."
    },
    {
        title: "Extended Interaction Range",
        category: "qol",
        tag: "QoL",
        icon: "maximize-2",
        desc: "Increases interaction distance up to 5x, allowing you to pick locks, grab keycards, and interact through grates from safe cover."
    },
    {
        title: "Instant Interaction / No Cooldown",
        category: "qol",
        tag: "QoL",
        icon: "timer",
        desc: "Instantly completes interactions like bag pickups, cable tying, lockpicking, and pager responses without waiting on progress bars."
    },
    {
        title: "Unlock All DLC Heists for Hosting",
        category: "qol",
        tag: "Crime.net",
        icon: "unlock",
        desc: "Unlocks every paid DLC heist on Crime.net so you can host any mission in PAYDAY 2 for your squad without purchasing DLC packs."
    },
    {
        title: "Multiplayer Safe Mode",
        category: "qol",
        tag: "Core",
        icon: "shield-check",
        desc: "Automatically neutralizes cheat-tier features when joining other hosts' multiplayer lobbies to protect against anti-cheat kicks and desyncs."
    },
    {
        title: "Single-Page In-Game Menu & Hotkeys",
        category: "qol",
        tag: "Core",
        icon: "sliders",
        desc: "Clean priority-sorted menu under Mod Options with category headers and no sub-menus. Includes an in-game hotkey keybind to toggle the mod on the fly."
    }
];

// ==========================================
// 3. UI RENDERING & EVENT HANDLING
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    const changelogList = document.getElementById('changelogList');
    const featuresGrid = document.getElementById('featuresGrid');
    const filterButtons = document.querySelectorAll('.filter-btn');
    const versionPill = document.querySelector('.version-pill');

    // Auto-sync latest version to the navbar pill
    if (versionPill && devlogs.length > 0) {
        versionPill.textContent = devlogs[0].version;
    }

    // Render Devlog / Changelog
    function renderDevlogs() {
        if (!changelogList) return;
        changelogList.innerHTML = '';

        devlogs.forEach(entry => {
            const card = document.createElement('div');
            card.className = `log-entry ${entry.isLatest ? 'latest' : ''}`;

            const itemsHtml = entry.items.map(item => `
                <li><strong>${item.label}:</strong> ${item.desc}</li>
            `).join('');

            card.innerHTML = `
                <div class="log-header">
                    <div class="log-version-row">
                        <span class="log-version">${entry.version}</span>
                        ${entry.isLatest ? '<span class="badge-current">CURRENT RELEASE</span>' : ''}
                    </div>
                    <span class="log-date">${entry.tag}</span>
                </div>
                <ul class="log-items">
                    ${itemsHtml}
                </ul>
            `;
            changelogList.appendChild(card);
        });
    }

    // Render Features Grid
    function renderFeatures(filter = 'all') {
        if (!featuresGrid) return;
        featuresGrid.innerHTML = '';

        const filtered = filter === 'all' 
            ? features 
            : features.filter(f => f.category === filter);

        filtered.forEach(item => {
            const card = document.createElement('div');
            card.className = 'feature-card';
            card.innerHTML = `
                <div class="card-top">
                    <div class="card-icon-box">
                        <i data-lucide="${item.icon}"></i>
                    </div>
                    <span class="card-tag">${item.tag}</span>
                </div>
                <h3 class="card-title">${item.title}</h3>
                <p class="card-desc">${item.desc}</p>
            `;
            featuresGrid.appendChild(card);
        });

        if (window.lucide) {
            lucide.createIcons();
        }
    }

    // Filter Buttons Click
    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            const filter = btn.getAttribute('data-filter');
            renderFeatures(filter);
        });
    });

    // Copy Path Button
    const copyBtn = document.getElementById('copyBtn');
    const installPath = document.getElementById('installPath');
    if (copyBtn && installPath) {
        copyBtn.addEventListener('click', () => {
            navigator.clipboard.writeText(installPath.textContent.trim()).then(() => {
                copyBtn.innerHTML = '<i data-lucide="check" class="btn-icon"></i>';
                if (window.lucide) lucide.createIcons();
                setTimeout(() => {
                    copyBtn.innerHTML = '<i data-lucide="copy" class="btn-icon"></i>';
                    if (window.lucide) lucide.createIcons();
                }, 2000);
            });
        });
    }

    // Initial Renders
    renderDevlogs();
    renderFeatures('all');
});
