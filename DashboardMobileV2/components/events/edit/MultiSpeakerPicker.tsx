// components/events/edit/MultiSpeakerPicker.tsx

import React, { useState, useMemo } from 'react';
import {
  View,
  Text,
  TextInput,
  FlatList,
  Pressable,
  useColorScheme,
  Platform,
} from 'react-native';
import styles from './editEvent.styles';

interface SpeakerOption {
  id: string;
  name: string;
}

interface Props {
  label: string;
  options: SpeakerOption[];
  selected: string[];
  onSelect: (name: string) => void;
  error?: string;
}

export function MultiSpeakerPicker({
  label,
  options,
  selected,
  onSelect,
  error,
}: Props) {
  const isDark = useColorScheme() === 'dark';
  const [query, setQuery] = useState('');
  const [showDropdown, setShowDropdown] = useState(false);

  // Filtrar opciones con protección contra valores null/undefined
  const filtered = useMemo(() => {
    const q = query.toLowerCase().trim();
    return options
      .filter(o => o.id && o.name)
      .filter(o => !selected.includes(o.name!))
      .filter(o =>
        !q ? true : o.name!.toLowerCase().includes(q)
      );
  }, [query, options, selected]);

  return (
    <View style={styles.inputContainer}>
      <Text style={[styles.label, { color: isDark ? '#FFF' : '#000' }]}>
        {label}
      </Text>

      {/* Tags de invitados especiales ya seleccionados */}
      <View style={styles.tagContainer}>
        {selected
          .filter(name => typeof name === 'string' && name.length > 0)
          .map(name => (
            <View
              key={`selected-${name}`} // ✅ KEY ÚNICA PARA TAGS
              style={[
                styles.tag,
                { backgroundColor: isDark ? '#2C2C2E' : '#E5E5EA' },
              ]}
            >
              <Text style={{ color: isDark ? '#FFF' : '#000' }}>{name}</Text>
              <Pressable onPress={() => onSelect(name)}>
                <Text style={{ color: '#FF3B30', marginLeft: 6 }}>✕</Text>
              </Pressable>
            </View>
          ))}
      </View>

      {/* Input para buscar invitados */}
      <Pressable
        onPress={() => setShowDropdown(v => !v)}
        style={[
          styles.dropdownInput,
          { backgroundColor: isDark ? '#2C2C2E' : '#F2F2F7' },
        ]}
      >
        <TextInput
          style={[
            styles.input,
            { color: isDark ? '#FFF' : '#000', flex: 1, paddingVertical: 8 },
            // En Web, quitamos el outline por defecto
            Platform.OS === 'web' ? { outlineWidth: 0 } : {},
          ]}
          placeholder="Type to search guests..."
          placeholderTextColor={isDark ? '#8E8E93' : '#3C3C43'}
          value={query}
          onChangeText={text => {
            setQuery(text);
            setShowDropdown(true);
          }}
        />
      </Pressable>

      {/* Lista desplegable */}
      {showDropdown && (
        <View
          style={[
            styles.dropdownListContainer,
            { backgroundColor: isDark ? '#1C1C1E' : '#FFF' },
          ]}
        >
          <FlatList
            data={filtered}
            keyExtractor={(item, index) => 
              `guest-option-${item.id}-${item.name}-${index}` // ✅ KEY ÚNICA MEJORADA
            }
            keyboardShouldPersistTaps="handled"
            renderItem={({ item }) => (
              <Pressable
                style={[
                  styles.dropdownItem,
                  { backgroundColor: isDark ? '#2C2C2E' : '#FFF' },
                ]}
                onPress={() => {
                  if (item.name) {
                    onSelect(item.name);
                    setQuery('');
                    setShowDropdown(false);
                  }
                }}
              >
                <Text style={{ color: isDark ? '#FFF' : '#000' }}>
                  {item.name}
                </Text>
              </Pressable>
            )}
            ListEmptyComponent={() => (
              <View style={styles.dropdownItem}>
                <Text style={{ color: isDark ? '#FFF' : '#000' }}>
                  No matches
                </Text>
              </View>
            )}
          />
        </View>
      )}

      {error && <Text style={styles.errorText}>{error}</Text>}
    </View>
  );
}

// ✅ FIN DEL ARCHIVO - NO AGREGAR MÁS CÓDIGO JSX AQUÍ
