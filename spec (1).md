# spec.md — Broto: App de Hábitos

> Este documento é a especificação técnica completa do app **Broto**, destinada ao Claude Code para implementação. Leia este arquivo inteiro antes de escrever qualquer código.

---

## Visão geral

**Broto** é um app mobile Flutter de rastreamento de hábitos diários. O usuário cria hábitos, marca conclusões diárias, acompanha streaks e recebe notificações locais de lembrete. O app funciona **100% offline** — sem backend, sem autenticação, sem internet.

**Plataforma alvo:** iOS (desenvolvido e testado em Mac Mini M4, simulador iPhone e dispositivo físico)  
**Framework:** Flutter (Dart)  
**Nível de complexidade do código:** básico — sem testes unitários, sem injeção de dependência avançada, sem abstrações desnecessárias. Prefira código direto e legível.

---

## Stack e dependências

```yaml
# pubspec.yaml — dependências completas
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^17.2.2
  table_calendar: ^3.1.2
  fl_chart: ^0.68.0
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  flutter_lints: ^4.0.0
```

**Não adicionar nenhuma dependência além das listadas acima.**

---

## Estrutura de pastas

Criar exatamente esta estrutura. Não criar subpastas além das definidas aqui.

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme.dart
│   └── router.dart
├── data/
│   ├── habit.dart
│   ├── habit.g.dart              ← gerado pelo build_runner
│   ├── habit_log.dart
│   ├── habit_log.g.dart          ← gerado pelo build_runner
│   └── hive_boxes.dart
├── providers/
│   ├── habits_provider.dart
│   └── logs_provider.dart
├── services/
│   ├── streak_service.dart
│   └── notification_service.dart
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_step1_screen.dart
│   │   ├── onboarding_step2_screen.dart
│   │   ├── onboarding_step3_screen.dart
│   │   └── onboarding_step4_screen.dart
│   ├── home_screen.dart
│   ├── add_habit_step1_screen.dart
│   ├── add_habit_step2_screen.dart
│   ├── habit_detail_screen.dart
│   ├── edit_habit_screen.dart
│   ├── stats_screen.dart
│   ├── notifications_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── app_button.dart
    ├── app_text_field.dart
    ├── habit_row_tile.dart
    ├── streak_card.dart
    ├── heatmap_grid.dart
    └── confirm_dialog.dart
```

---

## Paleta de cores e tema

Todas as cores estão centralizadas em `core/theme.dart`. **Nunca usar cores hardcoded nas telas.**

```dart
// core/theme.dart
class AppColors {
  static const deep    = Color(0xFF1E1B4B); // background principal
  static const surface = Color(0xFF2D2870); // cards e containers
  static const card    = Color(0xFF3C3489); // elementos secundários
  static const accent  = Color(0xFF7F77DD); // roxo principal (CTAs, ícones ativos)
  static const muted   = Color(0xFF534AB7); // roxo escuro (bordas, ícones inativos)
  static const soft    = Color(0xFFAFA9EC); // texto secundário
  static const lighter = Color(0xFFCECBF6); // texto de destaque suave
  static const text    = Color(0xFFEEEDFE); // texto primário
  static const navBg   = Color(0xFF26215C); // fundo da status bar e nav bar
  static const redDark = Color(0xFFA32D2D); // ações destrutivas
  static const redLight= Color(0xFFFCEBEB); // texto em ações destrutivas
}
```

**ThemeData** em `core/theme.dart`:

- `scaffoldBackgroundColor`: `AppColors.deep`
- `colorScheme.primary`: `AppColors.accent`
- `fontFamily`: sistema padrão do iOS
- `inputDecorationTheme`: fundo `AppColors.surface`, borda `AppColors.muted`, texto `AppColors.text`
- `elevatedButtonTheme`: fundo `AppColors.accent`, texto `AppColors.text`, border radius 10

---

## Modelos de dados (Hive)

### `Habit` — `data/habit.dart`

```dart
@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0) late int id;           // gerado com DateTime.now().millisecondsSinceEpoch
  @HiveField(1) late String name;
  @HiveField(2) late String icon;      // chave do ícone: 'water','brain','run','moon','book','activity','heart','pencil'
  @HiveField(3) late String color;     // hex: '#7F77DD','#1D9E75','#D85A30','#D4537E','#BA7517','#378ADD'
  @HiveField(4) late String frequency; // 'daily' | 'weekly' | 'weekdays'
  @HiveField(5) late String? reminderTime;  // 'HH:mm' ou null
  @HiveField(6) late List<int> reminderDays; // [1,2,3,4,5] = seg–sex; [] = sem lembrete
  @HiveField(7) late DateTime createdAt;
}
```

### `HabitLog` — `data/habit_log.dart`

```dart
@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  @HiveField(0) late int habitId;
  @HiveField(1) late DateTime date; // armazenar sempre com hora 00:00:00
  @HiveField(2) late bool completed;
}
```

### `hive_boxes.dart`

```dart
class HiveBoxes {
  static const String habits = 'habits';
  static const String logs   = 'logs';
}
```

Após criar os modelos, rodar:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Providers (Riverpod)

Usar `StateNotifier` simples. Não usar `AsyncNotifier` nem `FutureProvider` para listas — carregar no construtor e manter lista em memória.

### `providers/habits_provider.dart`

```dart
// Estado: List<Habit>
// Métodos públicos:
//   addHabit(Habit habit)    → salva no Hive, adiciona à lista, agenda notificação
//   updateHabit(Habit habit) → atualiza no Hive, atualiza na lista, reagenda notificação
//   deleteHabit(int id)      → remove do Hive, remove da lista, cancela notificação, apaga logs
//   loadHabits()             → carrega do Hive para a lista (chamado no init)
```

### `providers/logs_provider.dart`

```dart
// Estado: List<HabitLog>
// Métodos públicos:
//   toggleLog(int habitId, DateTime date)
//     → se log existe e completed=true: remove; senão: cria/atualiza com completed=true
//   getLogsForHabit(int habitId) → List<HabitLog>
//   getLogsForDate(DateTime date) → List<HabitLog>
//   deleteLogsForHabit(int habitId) → remove todos os logs do hábito
//   loadLogs() → carrega do Hive (chamado no init)
```

---

## Serviços

### `services/streak_service.dart`

Funções puras (sem estado). Recebem listas e retornam valores calculados.

```dart
class StreakService {
  // Retorna quantos dias consecutivos até hoje o hábito foi completado
  static int currentStreak(int habitId, List<HabitLog> logs);

  // Retorna o maior streak já registrado historicamente
  static int bestStreak(int habitId, List<HabitLog> logs);

  // Retorna taxa de conclusão no mês atual: diasCompletos / diasEsperados
  // diasEsperados = dias desde createdAt até hoje dentro do mês atual
  static double completionRate(int habitId, DateTime createdAt, List<HabitLog> logs);

  // Retorna Map<DateTime, bool> com os dias em que o hábito foi completado
  // para alimentar o TableCalendar
  static Map<DateTime, bool> calendarData(int habitId, List<HabitLog> logs);

  // Retorna lista de 7 doubles (0.0–1.0): taxa de conclusão de todos os hábitos
  // para cada um dos últimos 7 dias (índice 0 = 6 dias atrás, índice 6 = hoje)
  static List<double> weeklyCompletionRates(List<Habit> habits, List<HabitLog> logs);

  // Retorna Map<DateTime, int> com intensidade 0–4 baseada em quantos hábitos
  // foram completados naquele dia (para o heatmap das últimas 5 semanas)
  static Map<DateTime, int> heatmapData(List<Habit> habits, List<HabitLog> logs);
}
```

**Regras do streak:**

- Um dia conta se existe `HabitLog` com `habitId` correto, `date` igual ao dia (ignorar hora) e `completed = true`
- O streak quebra se qualquer dia entre `createdAt` e ontem não tiver log completo
- O dia de hoje não quebra o streak se ainda não foi marcado

### `services/notification_service.dart`

```dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Inicializar no main.dart antes do runApp
  static Future<void> initialize();

  // Solicitar permissão (iOS)
  static Future<void> requestPermissions();

  // Agendar lembrete diário para um hábito
  // Usar notificationId = habit.id (int)
  static Future<void> scheduleReminder(Habit habit);

  // Cancelar lembrete de um hábito
  static Future<void> cancelReminder(int habitId);

  // Cancelar todos os lembretes
  static Future<void> cancelAll();
}
```

---

## Navegação (`core/router.dart`)

Usar `GoRouter`. Rotas:

| Rota                | Tela                    |
|---------------------|-------------------------|
| `/onboarding/step1` | `OnboardingStep1Screen` |
| `/onboarding/step2` | `OnboardingStep2Screen` |
| `/onboarding/step3` | `OnboardingStep3Screen` |
| `/onboarding/step4` | `OnboardingStep4Screen` |
| `/home`             | `HomeScreen`            |
| `/habit/add/step1`  | `AddHabitStep1Screen`   |
| `/habit/add/step2`  | `AddHabitStep2Screen`   |
| `/habit/:id`        | `HabitDetailScreen`     |
| `/habit/:id/edit`   | `EditHabitScreen`       |
| `/stats`            | `StatsScreen`           |
| `/notifications`    | `NotificationsScreen`   |
| `/settings`         | `SettingsScreen`        |

**Redirect inicial:** verificar `SharedPreferences` pela chave `'onboarding_done'`. Se `false` ou ausente → `/onboarding/step1`. Se `true` → `/home`.

**Passagem de dados entre telas de formulário:** usar um `StateNotifier` simples chamado `HabitFormState` para guardar os dados entre step1 e step2 de criação/edição. Não usar `extra` do go_router para isso.

---

## Telas — especificação detalhada

### Onboarding

#### `onboarding_step1_screen.dart`

- Logo "🌱 Broto" centralizado, tagline "cultive seus hábitos, dia após dia"
- `AppTextField` com label "como podemos te chamar?"
- Botão "começar" → salva nome em `SharedPreferences` com chave `'user_name'` → navega para `/onboarding/step2`
- Validação: nome não pode estar vazio

#### `onboarding_step2_screen.dart`

- Barra de progresso: 2 de 4 segmentos ativos
- Título: "que hábitos quer cultivar?"
- Grade de chips selecionáveis com hábitos pré-definidos:
  `['Beber água', 'Meditar', 'Exercitar', 'Dormir cedo', 'Ler', 'Estudar', 'Caminhar', 'Alongar', 'Respirar']`
- Botão "continuar" (habilitado apenas se ≥ 1 chip selecionado) → navega para `/onboarding/step3`
- Botão ghost "criar hábito próprio" → navega para `/habit/add/step1`

#### `onboarding_step3_screen.dart`

- Barra de progresso: 3 de 4 segmentos ativos
- Título: "quando quer ser lembrado?"
- Lista dos hábitos selecionados na step2, cada um com um `TextButton` mostrando o horário
- Ao tocar no horário → `showTimePicker` → atualiza o horário do hábito
- Horário padrão: 08:00
- Botão "confirmar horários" → navega para `/onboarding/step4`

#### `onboarding_step4_screen.dart`

- Barra de progresso: 4 de 4 segmentos ativos
- Ícone de check em círculo roxo
- Título: "tudo pronto, [nome]!"
- Lista resumida dos hábitos com nome e horário
- Botão "começar a brotar" →
  1. Salva todos os hábitos via `habitsProvider`
  2. Salva `'onboarding_done': true` em `SharedPreferences`
  3. Navega para `/home` com `go()` (substituindo o stack)

---

### Home

#### `home_screen.dart`

- `Scaffold` com `BottomNavigationBar` de 4 abas: Home, Estatísticas, Notificações, Configurações
- Gerenciar aba ativa com `StatefulWidget` + `int _selectedIndex`
- Saudação: "Bom dia/tarde/noite, [nome]" baseada na hora atual
- Subtítulo: data atual + "X de Y feitos hoje"
- `LinearProgressIndicator` com valor `completedToday / totalToday`
- `StreakCard` com streak geral (maior streak entre todos os hábitos ativos)
- `ListView` de `HabitRowTile` para os hábitos do dia
- `FloatingActionButton` → navega para `/habit/add/step1`

**Estado vazio** (sem hábitos): exibir ícone de planta, texto "nenhum hábito ainda" e botão "criar primeiro hábito".

**Estado perfeito** (todos concluídos, `totalToday > 0`): exibir card especial "dia perfeito! 🏆" acima da lista.

**Pull-to-refresh:** `RefreshIndicator` que chama `ref.refresh()` nos providers.

---

### Hábito (CRUD)

#### `add_habit_step1_screen.dart`

- AppBar com "< novo hábito" e barra de progresso (1/2)
- `AppTextField` para nome
- Grade 4 colunas de ícones selecionáveis (usar `Icon` do Flutter com os ícones disponíveis — ver lista abaixo)
- Seletor de cor: 6 círculos coloridos clicáveis
- Seletor de frequência: 3 botões (Diário, Semanal, Dias úteis)
- Botão "próximo" → valida nome e ícone → salva em `HabitFormState` → navega para `/habit/add/step2`

**Ícones disponíveis** (mapear chave → `IconData`):

```dart
const Map<String, IconData> habitIcons = {
  'water':    Icons.water_drop_outlined,
  'brain':    Icons.psychology_outlined,
  'run':      Icons.directions_run,
  'moon':     Icons.nightlight_outlined,
  'book':     Icons.menu_book_outlined,
  'activity': Icons.favorite_outline,
  'heart':    Icons.self_improvement,
  'pencil':   Icons.edit_outlined,
};
```

#### `add_habit_step2_screen.dart`

- AppBar com "< novo hábito" e barra de progresso (2/2)
- Card preview com ícone e nome do hábito (lido do `HabitFormState`)
- `SwitchListTile` "ativar lembrete"
- Quando ativo: `TextButton` com horário atual → `showTimePicker`
- Seletor de dias da semana: 7 botões circulares (D S T Q Q S S), habilitados apenas se frequência for "weekly"
- Botão "salvar hábito" → cria o `Habit`, chama `habitsProvider.addHabit()` → volta para `/home`

#### `habit_detail_screen.dart`

- AppBar com nome do hábito e ícone de edição (navega para `/habit/:id/edit`)
- Card hero com ícone, nome e horário do lembrete
- 3 stat cards: sequência atual, melhor sequência, taxa do mês
- `TableCalendar` com dias marcados (dots) nos dias com log completo
  - `calendarFormat`: `CalendarFormat.month`
  - `selectedDayPredicate`: dia de hoje
  - `eventLoader`: retorna `[true]` se o dia tem log completo
- Navegação de meses com as setas do `TableCalendar`

#### `edit_habit_screen.dart`

- Mesmo layout do step1 + campo de horário, pré-populado com dados do hábito
- Botão "salvar alterações" → chama `habitsProvider.updateHabit()` → volta para `/habit/:id`
- Botão "excluir hábito" (vermelho, com ícone de lixeira) → abre `ConfirmDialog` → se confirmado: `habitsProvider.deleteHabit(id)` → navega para `/home`

---

### Stats

#### `stats_screen.dart`

- Grid 2×2 de stat cards: sequência atual geral, taxa geral do mês, hábitos ativos, melhor sequência histórica
- `BarChart` (fl_chart) dos últimos 7 dias
  - Dados: `StreakService.weeklyCompletionRates(habits, logs)`
  - Barras com cor `AppColors.accent` para dias ≥ 75%, `AppColors.muted` para os demais
  - Labels de dia da semana no eixo X
- `HeatmapGrid` das últimas 5 semanas
  - Dados: `StreakService.heatmapData(habits, logs)`
  - Legenda embaixo: "menos → mais" com 5 células de exemplo

---

### Notifications

#### `notifications_screen.dart`

- Lista de notificações salvas em `SharedPreferences` como JSON (`'notification_log'`)
- Cada item: ponto colorido, título, corpo, horário relativo ("hoje às 08:00", "ontem às 22:30")
- Estado vazio: texto "nenhuma notificação ainda"
- **Nota:** salvar notificação no log sempre que `scheduleReminder` for chamado — guardar título, corpo e timestamp

---

### Settings

#### `settings_screen.dart`

- Avatar com inicial do nome em círculo roxo
- Nome e "membro desde [mês] [ano]"
- Seção **NOTIFICAÇÕES** com 3 `SwitchListTile`:
  - "lembretes diários" → chave `'notif_reminders'`
  - "resumo noturno" → chave `'notif_summary'` (quando ativo, agendar notificação fixa às 22:30)
  - "alerta de streak" → chave `'notif_streak_alert'`
- Seção **APARÊNCIA** com 1 `SwitchListTile`:
  - "modo escuro" → por enquanto apenas salvar preferência, app sempre usa tema escuro
- Seção **DADOS**:
  - `ListTile` "redefinir todos os dados" → abre `ConfirmDialog` → se confirmado:
    1. `Hive.box(HiveBoxes.habits).clear()`
    2. `Hive.box(HiveBoxes.logs).clear()`
    3. `NotificationService.cancelAll()`
    4. Limpar todas as chaves do `SharedPreferences`
    5. Navegar para `/onboarding/step1` com `go()`

---

## Widgets compartilhados

### `widgets/app_button.dart`

```dart
// Parâmetros: String label, VoidCallback? onPressed, bool ghost = false, bool destructive = false
// ghost=true → borda AppColors.muted, sem preenchimento, texto AppColors.soft
// destructive=true → borda AppColors.redDark, texto AppColors.redDark
```

### `widgets/app_text_field.dart`

```dart
// Parâmetros: String label, TextEditingController controller, String? hint, bool obscure = false
// Estilo: fundo AppColors.surface, borda AppColors.muted, texto AppColors.text
```

### `widgets/habit_row_tile.dart`

```dart
// Parâmetros: Habit habit, bool completed, VoidCallback onToggle, VoidCallback onTap
// Layout: ícone colorido | nome + streak | checkbox animado
// Checkbox: AnimatedContainer que anima de borda AppColors.muted para preenchido AppColors.accent
// Duração da animação: 200ms
// onTap no tile → navega para /habit/:id
// onToggle no checkbox → chama logsProvider.toggleLog()
```

### `widgets/streak_card.dart`

```dart
// Parâmetros: int currentStreak, int bestStreak
// Layout: ícone de chama | número grande | "dias de sequência" | melhor streak à direita
```

### `widgets/heatmap_grid.dart`

```dart
// Parâmetros: Map<DateTime, int> data (intensidade 0–4)
// Grid 7 colunas × 5 linhas de células quadradas
// Cores por intensidade:
//   0 → AppColors.surface
//   1 → Color(0xFF3C3489)
//   2 → AppColors.muted
//   3 → AppColors.accent
//   4 → AppColors.lighter
```

### `widgets/confirm_dialog.dart`

```dart
// Parâmetros: String title, String message, String confirmLabel, bool destructive = false
// Retorna Future<bool> via showDialog
// Botão confirmar: vermelho se destructive=true, accent se false
// Botão cancelar: sempre ghost
```

---

## `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitLogAdapter());
  await Hive.openBox<Habit>(HiveBoxes.habits);
  await Hive.openBox<HabitLog>(HiveBoxes.logs);

  // 2. Inicializar notificações
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  // 3. Rodar app
  runApp(const ProviderScope(child: BrotoApp()));
}
```

---

## `app.dart`

```dart
class BrotoApp extends ConsumerWidget {
  const BrotoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Broto',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## Configuração iOS (`ios/Runner/Info.plist`)

Adicionar as seguintes chaves para notificações funcionarem:

```xml
<key>NSUserNotificationUsageDescription</key>
<string>O Broto usa notificações para lembrar você dos seus hábitos diários.</string>
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
<!-- Permitir HTTP local para testes (remover em produção) -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

---

## Regras gerais de implementação

1. **Sem testes.** Não criar nenhum arquivo em `test/`.
2. **Sem abstração desnecessária.** Se um widget é usado em apenas uma tela, pode ficar na própria tela como widget privado.
3. **Sem comentários em inglês.** Comentários, se necessários, em português.
4. **`StatelessWidget` por padrão.** Usar `StatefulWidget` apenas quando houver estado local real (formulários, animações, índice de aba).
5. **`ConsumerWidget` apenas quando necessário.** Não usar `Consumer` onde um `ref.watch` direto resolve.
6. **Hive é síncrono para leitura, assíncrono para escrita.** Usar `await` apenas nas operações de escrita (`put`, `add`, `delete`).
7. **Datas sem hora.** Sempre normalizar datas para meia-noite: `DateTime(date.year, date.month, date.day)`.
8. **Cores apenas de `AppColors`.** Nenhuma `Color(0x...)` fora de `core/theme.dart`.
9. **`go()` para substituir stack, `push()` para empilhar.** Usar `go()` nas transições entre fluxos (onboarding → home, settings → onboarding). Usar `push()` para detalhe e edição.
10. **`dart format` e `dart analyze` sem erros** antes de considerar qualquer arquivo completo.
11. **Separe bem os commits.** Ao completar cada pedaço do projeto, faça um commit explicativo e descritivo sobre a alteração implementada baseando-se nas regras de commits semânticos.

---

## Ordem de implementação sugerida

Seguir esta ordem para evitar dependências não resolvidas:

1. `core/theme.dart` e `core/router.dart` (esqueleto com rotas vazias)
2. `data/habit.dart`, `data/habit_log.dart`, `data/hive_boxes.dart` → rodar `build_runner`
3. `services/streak_service.dart` e `services/notification_service.dart`
4. `providers/habits_provider.dart` e `providers/logs_provider.dart`
5. `widgets/` (todos os widgets compartilhados)
6. `main.dart` e `app.dart`
7. Telas de onboarding (step1 → step4)
8. `home_screen.dart`
9. `add_habit_step1_screen.dart` e `add_habit_step2_screen.dart`
10. `habit_detail_screen.dart` e `edit_habit_screen.dart`
11. `stats_screen.dart`
12. `notifications_screen.dart`
13. `settings_screen.dart`

---

## O que NÃO implementar

- Testes unitários ou de integração
- Autenticação ou login
- Backend ou chamadas de rede
- Sincronização entre dispositivos
- Animações complexas além do `AnimatedContainer` no checkbox
- Internacionalização (app em português apenas)
- Acessibilidade avançada (Semantics)
