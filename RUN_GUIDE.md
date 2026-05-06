# 🚀 How to Run POSRest and Verify Everything Works

## ✅ Pre-flight Checklist

Before running, verify:
- ✅ Flutter installed: `flutter --version`
- ✅ Dart installed: `dart --version`
- ✅ Android/iOS SDK available: `flutter doctor`
- ✅ No compilation errors: All fixed! ✓

---

## 🏃 Step 1: Run the Application

### Option A: Run on Emulator (Recommended for Testing)

```bash
# Navigate to project
cd /Users/srithesh/Desktop/posrest

# Start emulator first (Android)
emulator -avd Nexus_5X_API_30 &

# Or use iOS simulator
open -a Simulator

# Run the app
flutter run
```

### Option B: Run on Physical Device

```bash
# Connect device via USB and enable USB debugging
# Then:
cd /Users/srithesh/Desktop/posrest
flutter run
```

### Option C: Run on Web (Preview Only)

```bash
flutter run -d chrome
```

---

## 📱 What You Should See (Step-by-Step)

### **Screen 1: Login Screen** ✅
```
Display: 
├── App logo (🍽️ POSRest)
├── Email field (demo@posrest.com)
├── Password field (demo123)
├── Sign In button
└── Demo Login button
```

**What to do:**
- Tap "Demo Login" button
- OR enter email/password and tap "Sign In"

### **Screen 2: Table Management Screen** ✅
```
Display:
├── AppBar with "Tables" title
├── Filter chips (All, Free: 12, Occupied: 0, Reserved: 0)
├── 12 Table cards in 3-column grid:
│   ├── Table 1 (Capacity: 2) - Green status
│   ├── Table 2 (Capacity: 2) - Green status
│   └── ... Table 12 (Capacity: 6) - Green status
└── FAB (+) button for creating new tables
```

**Tables Created Automatically:**
- Tables 1-4: Capacity 2 seats each (Green = Free)
- Tables 5-8: Capacity 4 seats each (Green = Free)  
- Tables 9-12: Capacity 6 seats each (Green = Free)

**What to do:**
1. See all tables are green (Free status)
2. Tap on any table → goes to Order Screen

### **Screen 3: Order Screen** ✅
```
Display:
Left Panel (Menu):
├── Category tabs (Starters, Main Course, Drinks, Desserts)
└── 2-column grid of menu items

Right Panel (Order Cart):
├── "Current Order" header (green)
├── Empty items list
├── Totals section:
│   ├── Subtotal: ₹0
│   ├── Tax (5%): ₹0
│   └── Total: ₹0
└── Action buttons (Cancel, Send to Kitchen)
```

**What to do:**
1. Click category tab (e.g., "Main Course")
2. Menu items appear on left side
3. Click menu item card

### **Screen 4: Item Details Dialog** ✅
```
Display:
├── Item name
├── Description
├── Price in green
├── Quantity selector (-/+ buttons)
├── Special instructions field
└── "Add to Order" button
```

**What to do:**
1. Adjust quantity with +/- buttons
2. Add special notes (optional)
3. Click "Add to Order"

### **Screen 5: Updated Order Cart** ✅
```
After adding item:

Right Panel Shows:
├── Order Items:
│   ├── Butter Chicken × 1    ₹320
│   └── Delete button (X)
├── Subtotal: ₹320.00
├── Tax (5%): ₹16.00
└── Total: ₹336.00

(All update in real-time!)
```

**Verification Points:**
- ✅ Item appears in cart
- ✅ Quantity shows correctly
- ✅ Subtotal = item price
- ✅ Tax = Subtotal × 0.05
- ✅ Total = Subtotal + Tax

---

## 🧪 Complete Test Workflow

### Test 1: Single Item Order

```
1. Login → See 12 tables (all green)
2. Click Table 1 → Order screen
3. Click "Main Course" category
4. Click "Butter Chicken" item (₹320)
5. Quantity = 1, click "Add to Order"
6. Verify:
   ✓ Item in cart
   ✓ Subtotal: ₹320
   ✓ Tax: ₹16
   ✓ Total: ₹336
```

### Test 2: Multiple Items Order

```
1. From order screen, add another item:
   - Click "Starters"
   - Click "Paneer Tikka" (₹180)
   - Quantity = 1, add
2. Verify cart shows:
   ✓ Butter Chicken × 1: ₹320
   ✓ Paneer Tikka × 1: ₹180
   ✓ Subtotal: ₹500
   ✓ Tax: ₹25
   ✓ Total: ₹525
```

### Test 3: Modify Quantity

```
1. In order cart, find "Butter Chicken" item
2. Click quantity control
3. Change from 1 to 2
4. Verify:
   ✓ Item shows "× 2"
   ✓ Item price = ₹640 (2 × 320)
   ✓ Subtotal updates: ₹820
   ✓ Tax updates: ₹41
   ✓ Total updates: ₹861
```

### Test 4: Remove Item

```
1. In order cart, find delete button (X)
2. Click to remove "Paneer Tikka"
3. Verify:
   ✓ Item removed from cart
   ✓ Only "Butter Chicken × 2" remains
   ✓ Subtotal: ₹640
   ✓ Tax: ₹32
   ✓ Total: ₹672
```

### Test 5: Cancel Order

```
1. Click "Cancel" button
2. Verify:
   ✓ Returns to table screen
   ✓ Table 1 still shows green (Free)
   ✓ Order was not saved (as expected)
```

### Test 6: Send to Kitchen

```
1. Create new order with items
2. Click "Send to Kitchen"
3. Verify:
   ✓ Order sent
   ✓ Returns to table screen
   ✓ (In Phase 2: Table will show Red/Occupied)
```

---

## 📊 Expected Data Verification

### Default Menu (Verify this loads)

**Starters:**
- ✅ Samosa - ₹80 (Vegetarian, Spicy)
- ✅ Paneer Tikka - ₹180 (Vegetarian)

**Main Course:**
- ✅ Butter Chicken - ₹320 (Non-Veg)
- ✅ Biryani - ₹280 (Non-Veg, Spicy)

**Drinks:**
- ✅ Lassi - ₹60 (Vegetarian)
- ✅ Mango Juice - ₹80 (Vegetarian)

**Desserts:**
- ✅ Gulab Jamun - ₹100 (Vegetarian)

---

## 🔍 Debugging Output (Check Terminal)

When you run `flutter run`, you should see:

```
✅ Gradle Build Output:
Building APK for release...
✅ Connected device:
- Android device or emulator name

✅ App logs:
I/flutter: AuthService initialized
I/flutter: PreferencesService initialized
I/flutter: Database created successfully
I/flutter: Default tables created
I/flutter: Default menu loaded
```

---

## 🐛 Troubleshooting

### Issue 1: App Won't Start

**Error:** `Failed to build APK`

**Solution:**
```bash
flutter clean
flutter pub get
flutter run -v  # Verbose to see exact error
```

### Issue 2: Emulator Too Slow

**Solution:**
```bash
# Use web preview instead
flutter run -d chrome

# Or use physical device
flutter run -d <device_id>
```

### Issue 3: Database Errors

**Error:** `Database initialization failed`

**Solution:**
```bash
flutter clean
# Uninstall app from device
adb uninstall com.example.posrest
flutter run
```

### Issue 4: Can't Login

**Check:**
- ✅ AuthService initialized (check logs)
- ✅ SharedPreferences available
- ✅ Use demo credentials exactly: `demo@posrest.com` / `demo123`

### Issue 5: Tables Don't Show

**Check:**
- ✅ TableController loaded tables
- ✅ Database created 12 default tables
- ✅ Refresh by going back and forth

---

## ✅ Verification Checklist

After running, verify ALL of these:

**Login & Auth:**
- [ ] Can login with demo credentials
- [ ] Redirects to table screen after login
- [ ] Can see "Sign In" button is clickable

**Table Management:**
- [ ] See exactly 12 tables
- [ ] All tables show green color (Free status)
- [ ] Table numbers: 1-12 displayed correctly
- [ ] Capacity shows correctly (2, 4, or 6)
- [ ] Filter chips show count (All: 12, Free: 12)

**Order Creation:**
- [ ] Click table → goes to order screen
- [ ] Menu loads with all 4 categories
- [ ] 7 menu items visible
- [ ] Item prices displayed
- [ ] Vegetarian indicator shows (green leaf icon)

**Calculations:**
- [ ] Add Samosa (₹80) → Subtotal ₹80, Tax ₹4, Total ₹84 ✓
- [ ] Add Butter Chicken (₹320) → Subtotal ₹400, Tax ₹20, Total ₹420 ✓
- [ ] Change quantity to 2 → Recalculates correctly ✓
- [ ] Remove item → Recalculates correctly ✓

**UI/UX:**
- [ ] Smooth animations (fade in/scale)
- [ ] No glitches or layout issues
- [ ] Text readable with good contrast
- [ ] Buttons responsive and clickable
- [ ] No console errors (check terminal)

**Database:**
- [ ] Data persists after closing app
- [ ] Default data loads on first run
- [ ] No "Database error" messages

---

## 🎯 Success Criteria

**You'll know everything works when:**
1. ✅ App launches without errors
2. ✅ Login screen appears
3. ✅ Demo login works
4. ✅ See 12 green tables
5. ✅ Can create order with items
6. ✅ Calculations are correct
7. ✅ No errors in terminal/console
8. ✅ Can go back and forth between screens
9. ✅ All menu items load
10. ✅ App doesn't crash

---

## 📱 Command Reference

| Command | Purpose |
|---------|---------|
| `flutter run` | Run app on device/emulator |
| `flutter run -d chrome` | Run web preview |
| `flutter clean` | Clean build files |
| `flutter pub get` | Get dependencies |
| `flutter pub upgrade` | Update all packages |
| `flutter doctor` | Check environment |
| `flutter logs` | See app logs |
| `flutter devices` | List connected devices |

---

## 💡 Tips for Testing

### Tip 1: Fast Iteration
Use hot reload (press `r` during `flutter run`) to see changes without rebuilding:
```
✓ Change colors in app_theme.dart
✓ Update text labels
✓ Modify UI layouts
```

### Tip 2: Simulate Different Devices
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Tip 3: Monitor Console Output
Keep terminal visible to see:
- ✓ Build progress
- ✓ App logs
- ✓ Errors/warnings
- ✓ Performance metrics

### Tip 4: Test On Multiple Screen Sizes
- Small phone (4.5")
- Regular phone (5.5")
- Tablet (7"+)

---

## 📞 Getting Help

### Check These Files:
1. **QUICK_START.md** - Quick reference
2. **README.md** - Full documentation
3. **IMPLEMENTATION_GUIDE.md** - Architecture
4. **PROJECT_SUMMARY.md** - Technical details

### Common Log Messages:

**Good Signs:**
```
✓ "AuthService initialized"
✓ "PreferencesService initialized"
✓ "Database created successfully"
✓ "Default tables created"
✓ "Default menu loaded"
```

**Bad Signs:**
```
✗ "Compilation error"
✗ "Database error"
✗ "Import not found"
✗ "Widget not found"
```

---

## 🎉 You're Ready!

Everything is implemented and ready to run.

**Next steps:**
1. Run `flutter run`
2. Verify all test points above
3. Once working, start Phase 2 (Billing system)

**Estimated runtime:** 1-2 minutes for first build

---

**Last Updated:** May 6, 2026  
**Status:** ✅ Ready to Run  
**All Errors:** ✅ Fixed (0 errors)
